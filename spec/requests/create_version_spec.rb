RSpec.describe 'POST /services/:id/versions' do
  let(:response_body) { JSON.parse(response.body) }
  let(:service) { create(:service) }

  before do
    post "/services/#{service.id}/versions", params: params, as: :json
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
            },
            {
              "_id": "page.upload-cop1a",
              "_type": "page.singlequestion",
              "components": [
                {
                  "_id": "page.upload-cop1a--upload.auto_name__1",
                  "_type": "upload",
                 "errors": {},
                  "hint": "",
                  "label": "Upload your completed supporting information (COP1A)",
                  "name": "upload-cop1a"
                }
              ],
              "steps": [
                "page.upload-cop1a-check"
              ],
              "url": "upload-cop1a"
            },
          ],
          "locale": "en"
        }
      }
    end

    it 'returns created status' do
      expect(response.status).to be(201)
    end

    it 'returns the metadata' do
      expected = {
        "service_id" => service.id,
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
          },
          {
            "_id" => "page.upload-cop1a",
            "_type" => "page.singlequestion",
            "components" => [
              {
                "_id" => "page.upload-cop1a--upload.auto_name__1",
                "_type" => "upload",
               "errors" => {},
                "hint" => "",
                "label" => "Upload your completed supporting information (COP1A)",
                "name" => "upload-cop1a"
              }
            ],
            "steps" => [
              "page.upload-cop1a-check"
            ],
            "url" => "upload-cop1a"
          },
        ],
        "locale" => "en"
      }
      expect(response_body).to include(expected)
    end
  end

  context 'when invalid attributes' do
    let(:params) { { metadata: {'foo': 'bar'}} }

    it 'returns unprocessable entity' do
      expect(response.status).to be(422)
    end

    it 'returns error messages' do
      expect(response_body['message']).to eq(
        [
          "Metadata created by can't be blank",
          "Name can't be blank",
          "Created by can't be blank"
        ]
      )
    end
  end
end
