# frozen_string_literal: true

RSpec.describe PdfServer do
  # login to http basic auth
  include AuthHelper
  before do
    http_login
  end

  class DummyReportHelper

    def get_default_template(report_type)
    end

    def upload_to_S3(year, business_npwd, report_type, file_location)
    end
  end

  class DummyPdftk
    def get_fields(report)
    end
    def fill_form(report_type, file_location, values)
    end
  end

  subject(:pdf_server) { described_class.new }
  let(:dummy_report_helper) { DummyReportHelper.new }
  let(:dummy_pdftk) { DummyPdftk.new }
  let(:year) { '2017' }
  let(:npwd) { 'NPWD_TEST' }
  let(:report_type) { 'TEST_REPORT' }
  let(:response) { { response_body: report_type, target: 'tmp/my_dir' } }
  let(:file_location) { 'temp/TEST_REPORT_2017_NPWD_TEST.pdf' }
  let(:params) do
    {
      values: { key: 'value' }.to_json,
      year: year,
      business_npwd: npwd,
      report_type: report_type
    }
  end
  describe '#POST create/pdf' do
    it 'expects the status code to be 200' do
      allow(S3ReportHelper).to receive(:new).and_return(dummy_report_helper)
      allow(PdfForms).to receive(:new).and_return(dummy_pdftk)
      allow(dummy_report_helper).to receive(:get_default_template).and_return(response)
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(last_response.status).to eq 200
     end

    it 'expects the default template to be downloaded' do
      allow(S3ReportHelper).to receive(:new).and_return(dummy_report_helper)
      allow(PdfForms).to receive(:new).and_return(dummy_pdftk)
      allow(dummy_report_helper).to receive(:get_default_template).and_return(response)
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(dummy_report_helper).to have_received(:get_default_template).with(report_type)
    end

    it 'expects the pdf form to be filled in' do
      allow(S3ReportHelper).to receive(:new).and_return(dummy_report_helper)
      allow(PdfForms).to receive(:new).and_return(dummy_pdftk)
      allow(dummy_report_helper).to receive(:get_default_template).and_return(response)
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

     expect(dummy_pdftk).to have_received(:fill_form).with(report_type, file_location, JSON.parse(params[:values]))
    end

    it 'expects the created pdf to be uploaded to S3' do
      allow(S3ReportHelper).to receive(:new).and_return(dummy_report_helper)
      allow(PdfForms).to receive(:new).and_return(dummy_pdftk)
      allow(dummy_report_helper).to receive(:get_default_template).and_return(response)
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(dummy_report_helper).to have_received(:upload_to_S3).with(year, npwd, report_type, file_location)
    end
    context 'when an error occurs' do
      it 'expects a 422 status code' do
        allow(S3ReportHelper).to receive(:new).and_return(dummy_report_helper)
        allow(PdfForms).to receive(:new).and_return(dummy_pdftk)
        allow(dummy_report_helper).to receive(:get_default_template).and_raise StandardError
        allow(dummy_pdftk).to receive(:fill_form)
        allow(dummy_report_helper).to receive(:upload_to_S3)

        post '/api/v1/create/pdf/', params

        expect(last_response.status).to eq 422
      end
    end
  end
end