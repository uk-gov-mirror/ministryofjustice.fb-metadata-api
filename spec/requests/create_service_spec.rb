RSpec.describe 'POST /services', type: :request do
  include_examples 'application authentication' do
    let(:action) do
      post '/services', params: {}, as: :json
    end
  end
  let(:response_body) { JSON.parse(response.body) }

  before do
    allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_return(true)
    post '/services', params: params, as: :json
  end

  context 'when valid attributes' do
    let(:params) do
      {
        "metadata": {
          "service_name": "Service Name",
          "created_by": "4634ec01-5618-45ec-a4e2-bb5aa587e751",
          "configuration": {
             "_id": "service",
             "_type": "config.service"
           },
          "pages": [
            {
              "_id": "page.start",
              "_type": "page.start",
              "url": "/"
            }
          ],
          "locale": "en"
        }
      }
    end

    it 'returns created status' do
      expect(response.status).to be(201)
    end

    it 'returns service representation' do
      expected = {
        "service_name" => "Service Name",
        "created_by" => "4634ec01-5618-45ec-a4e2-bb5aa587e751",
        "configuration" => {
          "_id" => "service",
          "_type" => "config.service"
        },
        "pages" => [
          {
            "_id" => "page.start",
            "_type" => "page.start",
            "url" => "/"
          }
        ],
        "locale" => "en"
      }
      expect(response_body).to include(expected)
    end

    it 'returns service id' do
      expect(
        Service.exists?(response_body["service_id"])
      ).to be_truthy
    end

    it 'returns version id' do
      expect(
        Metadata.exists?(response_body["version_id"])
      ).to be_truthy
    end
  end

  context 'when no locale is in the metadata' do
    let(:params) do
      {
        metadata: {
          service_name: 'Service Name',
          created_by: '4634ec01-5618-45ec-a4e2-bb5aa587e751'
        }
      }
    end

    it 'should set en as the default' do
      expect(response_body['locale']).to eq('en')
    end
  end

  context 'when a locale is in the metadata' do
    let(:params) do
      {
        metadata: {
          service_name: 'Helo Byd',
          created_by: '4634ec01-5618-45ec-a4e2-bb5aa587e751',
          locale: 'cy'
        }
      }
    end

    it 'should set en as the default' do
      expect(response_body['locale']).to eq('cy')
    end
  end


  context 'when invalid attributes' do
    let(:params) { {} }

    it 'returns unprocessable entity' do
      expect(response.status).to be(422)
    end

    it 'returns error message' do
      expect(response_body['message']).to match_array(
        [
          "Metadata locale can't be blank",
          "Metadata data can't be blank",
          "Metadata created by can't be blank",
          "Name can't be blank",
          "Created by can't be blank"
        ]
      )
    end
  end
end
