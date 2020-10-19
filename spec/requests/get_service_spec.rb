RSpec.describe 'GET /services/:id' do
  let(:response_body) { JSON.parse(response.body) }

  context 'when service exists' do
    let(:service) do
      create(:service,
             metadata: [first_version, latest_version])
    end
    let(:first_version) do
      build(:metadata)
    end
    let(:latest_version) do
      build(:metadata, data: {
        configuration: {
          email_input_name_user: 'mojo'
        },
        pages: []
      })
    end

    before do
      get "/services/#{service.id}", as: :json
    end

    it 'returns success response' do
      expect(response.status).to be(200)
    end

    it 'returns metadata' do
      expect(response_body).to eq({
        "configuration" => { "email_input_name_user" => "mojo" },
        "created_by" => latest_version.created_by,
        "locale" => "en",
        "pages" => [],
        "service_id" => service.id,
        "service_name" => service.name,
        "version_id" => latest_version.id
      })
    end
  end

  context 'when service does not exist' do
    before do
      get "/services/1234-abcdef", as: :json
    end

    it 'returns not found response' do
      expect(response.status).to be(404)
    end

    it 'returns not found message' do
      expect(response_body).to eq({
        'message' => ['Requested Service not found']
      })
    end
  end
end
