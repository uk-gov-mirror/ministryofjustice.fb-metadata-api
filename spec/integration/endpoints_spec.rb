require_relative 'metadata_api_test_client'

RSpec.describe 'API integration tests' do
  let(:metadata_api_test_client) { MetadataApiTestClient.new }
  let(:jwt_payload) do
    { iss: 'integration-tests', namespace: 'awesome-namespace', iat: Time.now.to_i }
  end
  let(:private_key) do
    key = File.read(Rails.root.join('spec', 'fixtures', 'private.pem'))
    OpenSSL::PKey::RSA.new(key)
  end
  let(:access_token) do
    JWT.encode(
      jwt_payload,
      private_key,
      'RS256'
    )
  end
  let(:authorisation_headers) do
    { Authorization: "Bearer #{access_token}" }
  end
  let(:service) do
    JSON.parse(
      File.read(fixtures_directory.join('service.json'))
    ).deep_symbolize_keys
  end
  let(:version) do
    JSON.parse(
      File.read(fixtures_directory.join('version.json'))
    ).deep_symbolize_keys
  end
  let(:request_body) { { "metadata": service }.to_json }

  def parse_response(response)
    JSON.parse(response.body, symbolize_names: true)
  end

  context 'when passing valid authorisation token' do
    context 'when a new service is created' do
      it 'we can request a specific version' do
        response = metadata_api_test_client.create_service(
          body: { "metadata": service }.to_json,
          authorisation_headers: authorisation_headers
        )

        metadata = parse_response(response)
        expect(response.code).to be(201)
        expect(metadata).to include(service)

        service_id = metadata[:service_id]
        version_id = metadata[:version_id]
        response = metadata_api_test_client.get_version(
          service_id: service_id,
          version_id: version_id,
          authorisation_headers: authorisation_headers
        )

        metadata = parse_response(response)
        expect(response.code).to be(200)
        expect(metadata).to include(
          service.merge({ service_id: service_id, version_id: version_id })
        )
      end
    end

    context 'when creating a new version of a service' do
      it 'returns the newly created service version' do
        response = metadata_api_test_client.create_service(
          body: request_body,
          authorisation_headers: authorisation_headers
        )
        metadata = parse_response(response)

        updated_payload = { "metadata": version.merge(service_id: metadata[:service_id]) }
        response = metadata_api_test_client.new_version(
          service_id: metadata[:service_id],
          body: updated_payload.to_json,
          authorisation_headers: authorisation_headers
        )

        updated_metadata = parse_response(response)
        expect(response.code).to be(201)
        expect(updated_metadata).to include(pages: version[:pages])
      end
    end

    context 'getting all versions of a service' do
      it 'returns all the versions for that service' do
        response = metadata_api_test_client.create_service(
          body: request_body,
          authorisation_headers: authorisation_headers
        )
        metadata = parse_response(response)

        versions = [
          {
            version_id: metadata[:version_id],
            created_at: metadata[:created_at]
          }
        ]

        versions << 3.times.map do
          new_version = parse_response(metadata_api_test_client.new_version(
            service_id: metadata[:service_id],
            body: { "metadata": metadata }.to_json,
            authorisation_headers: authorisation_headers
          ))

          {
            version_id: new_version[:version_id],
            created_at: new_version[:created_at]
          }
        end

        response = metadata_api_test_client.all_versions(
          service_id: metadata[:service_id],
          authorisation_headers: authorisation_headers
        )

        all_versions = parse_response(response)
        expect(all_versions[:versions]).to eq(versions.flatten.reverse)

        response = metadata_api_test_client.get_latest_version(
          service_id: metadata[:service_id],
          authorisation_headers: authorisation_headers
        )

        latest_version = parse_response(response)
        expect(all_versions[:versions].first[:version_id]). to eq(latest_version[:version_id])
      end
    end

    context 'getting services for a user' do
      let(:user_id) { SecureRandom.uuid }

      it 'should return all the services that user contributed to' do
        services = 2.times.map do
          new_service = parse_response(metadata_api_test_client.create_service(
            body: { "metadata": service.merge("created_by": user_id) }.to_json,
            authorisation_headers: authorisation_headers
          ))

          {
            service_id: new_service[:service_id],
            service_name: new_service[:service_name],
          }
        end
        metadata_api_test_client.create_service(
          body: { "metadata": service.merge("created_by": SecureRandom.uuid) }.to_json,
          authorisation_headers: authorisation_headers
        )

        services_for_user = parse_response(metadata_api_test_client.get_services_for_user(
          user_id: user_id,
          authorisation_headers: authorisation_headers
        ))[:services]

        expect(services_for_user).to match_array(services.flatten)
      end
    end

    context 'when resource is not found' do
      context 'when the service is not found' do
        let(:service_id) { SecureRandom.uuid }

        it 'returns 404 with a message' do
          response = metadata_api_test_client.get_latest_version(
            service_id: service_id,
            authorisation_headers: authorisation_headers
          )

          expect(response.code).to be(404)
          expect(
            parse_response(response)[:message]
          ).to match_array(["Couldn't find Service with 'id'=#{service_id}"])

          response = metadata_api_test_client.get_version(
            service_id: service_id,
            version_id: SecureRandom.uuid,
            authorisation_headers: authorisation_headers
          )

          expect(response.code).to be(404)
          expect(
            parse_response(response)[:message]
          ).to match_array(["Couldn't find Service with 'id'=#{service_id}"])
        end
      end

      context 'when metadata version is not found' do
        let(:version_id) { SecureRandom.uuid }

        it 'returns not found with a message' do
          response = metadata_api_test_client.create_service(
            body: request_body,
            authorisation_headers: authorisation_headers
          )
          service_id = parse_response(response)[:service_id]

          response = metadata_api_test_client.get_version(
            service_id: service_id,
            version_id: version_id,
            authorisation_headers: authorisation_headers
          )

          expect(response.code).to be(404)
          expect(
            parse_response(response)[:message]
          ).to match_array(["Couldn't find Metadata Version with 'id'=#{version_id}"])
        end
      end
    end

    context 'when not passing required metadata attributes' do
      it 'returns unprocessable entity with a message for create service' do
        response = metadata_api_test_client.create_service(
          body: { "metadata": {} }.to_json,
          authorisation_headers: authorisation_headers
        )

        expect(response.code).to be(422)
        expect(
          parse_response(response)[:message]
        ).to match_array(
          ["The property '#/metadata' did not contain a required property of '_id'"]
        )
      end

      it 'returns unprocessable entity with a message for new version service' do
        response = metadata_api_test_client.new_version(
          service_id: '4634ec01-5618-45ec-a4e2-bb5aa587e751',
          body: { "metadata": {} }.to_json,
          authorisation_headers: authorisation_headers
        )

        expect(response.code).to be(422)
        expect(
          parse_response(response)[:message]
        ).to match_array(
          ["The property '#/metadata' did not contain a required property of '_id'"]
        )
      end
    end
  end

  context 'when not passing authorisation token' do
    it 'returns a forbidden response with token not present message ' do
      response = metadata_api_test_client.create_service(body: {}, authorisation_headers: {})

      expect(response.code).to be(403)
      expect(parse_response(response)[:message]).to match_array(['Token is not present'])
    end
  end

  context 'when not passing a issuer' do
    let(:jwt_payload) do
      { namespace: 'awesome-namespace', iat: Time.now.to_i }
    end

    it 'returns 403 with issuer not present message' do
      response = metadata_api_test_client.create_service(
        body: request_body,
        authorisation_headers: authorisation_headers
      )

      expect(response.code).to be(403)
      expect(
        parse_response(response)[:message]
      ).to match_array(['Issuer is not present in the token'])
    end
  end

  context 'when not passing a namespace' do
    let(:jwt_payload) do
      { iss: 'integration-tests', iat: Time.now.to_i }
    end

    it 'returns 403 with namespace not present message' do
      response = metadata_api_test_client.create_service(
        body: request_body,
        authorisation_headers: authorisation_headers
      )

      expect(response.code).to be(403)
      expect(
        parse_response(response)[:message]
      ).to match_array(['Namespace is not present in the token'])
    end
  end

  context 'when token is expired' do
    let(:jwt_payload) do
      {
        iss: 'integration-tests',
        namespace: 'awesome-namespace',
        iat: (Time.now - 24.hours).to_i
      }
    end

    it 'returns 403 with a token has expired message' do
      response = metadata_api_test_client.create_service(
        body: request_body,
        authorisation_headers: authorisation_headers
      )

      expect(response.code).to be(403)
      expect(
        parse_response(response)[:message]
      ).to match_array(['Token has expired: iat skew is -86400, max is 60'])
    end
  end

  context 'when route does not exist' do
    let(:response) do
      MetadataApiTestClient.get(
        '/services/i-dont-exist-9999',
        headers: authorisation_headers
      )
    end

    it 'returns not found' do
      expect(response.code).to be(404)
    end

    it 'returns a error message' do
      expect(
        JSON.parse(response.body, symbolize_names: true)[:message]
      ).to eq(["No route matches GET '/services/i-dont-exist-9999'"])
    end
  end
end
