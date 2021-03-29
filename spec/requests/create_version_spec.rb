RSpec.describe 'POST /services/:id/versions' do
  let(:response_body) { JSON.parse(response.body) }
  let(:service) { create(:service) }

  before do
    allow_any_instance_of(Fb::Jwt::Auth).to receive(:verify!).and_return(true)
    post "/services/#{service.id}/versions", params: params, as: :json
  end
  let(:version) do
    JSON.parse(
      File.read(fixtures_directory.join('version.json'))
    ).merge(service_id: service.id).deep_symbolize_keys
  end

  context 'when valid attributes' do
    let(:params) { { metadata: version } }

    it 'returns created status' do
      expect(response.status).to be(201)
    end

    it 'returns the metadata' do
      expect(response_body.deep_symbolize_keys).to include(version)
    end
  end

  context 'when invalid attributes' do
    let(:params) { { metadata: { 'foo': 'bar' } } }

    it 'returns unprocessable entity' do
      expect(response.status).to be(422)
    end

    it 'returns error messages' do
      expect(
        response_body['message']
      ).to eq(
        ["The property '#/metadata' did not contain a required property of '_id'"]
      )
    end

    context 'when adding an input component to a content page' do
      let(:version) do
        JSON.parse(
          File.read(fixtures_directory.join('invalid_content_page.json'))
        ).merge(service_id: service.id).deep_symbolize_keys
      end
      let(:params) { { metadata: version } }

      it 'returns unprocessable entity' do
        expect(response.status).to be(422)
      end

      it 'returns error messages' do
        expect(
          response_body['message']
        ).to eq(
          ["The property '#/components/0' did not contain a required property of 'html'"]
        )
      end
    end
  end
end
