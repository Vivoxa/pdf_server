# frozen_string_literal: true

RSpec.describe PdfServer do
  # login to http basic auth
  include AuthHelper
  before do
    http_login
    allow(S3ReportHelper).to receive(:new).and_return(dummy_report_helper)
    allow(PdfForms).to receive(:new).and_return(dummy_pdftk)
    allow(dummy_report_helper).to receive(:get_default_template).and_return(response)
    allow(dummy_report_helper).to receive(:upload_to_S3)
  end

  def app
    pdf_server
  end

  # dummy class
  class DummyReportHelper

    def get_default_template(report_type)
    end

    def upload_to_S3(year, business_npwd, report_type, file_location)
    end

    def get_report(year, business_npwd, report_type)

    end
  end

  # dummy class
  class DummyPdftk
    def get_fields(report)
    end

    def fill_form(report_type, file_location, values)
    end
  end

  subject(:pdf_server) { described_class.new! }
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
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(last_response.status).to eq 200
     end

    it 'expects the default template to be downloaded' do
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(dummy_report_helper).to have_received(:get_default_template).with(report_type)
    end

    it 'expects the pdf form to be filled in' do
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(dummy_pdftk).to have_received(:fill_form).with(report_type, file_location, JSON.parse(params[:values]))
    end

    it 'expects the created pdf to be uploaded to S3' do
      allow(dummy_pdftk).to receive(:fill_form)
      allow(dummy_report_helper).to receive(:upload_to_S3)

      post '/api/v1/create/pdf/', params

      expect(dummy_report_helper).to have_received(:upload_to_S3).with(year, npwd, report_type, file_location)
    end
    context 'when errors occur' do
      context 'when the report template cannot be found' do
        it 'expects a 404 status code' do
          allow(dummy_report_helper).to receive(:get_default_template).and_raise StandardError
          allow(dummy_pdftk).to receive(:fill_form)

          post '/api/v1/create/pdf/', params

          expect(last_response.status).to eq 404
        end
      end

      context 'when the pdf form fill fails' do
        it 'expects a 422 status code' do
          allow(dummy_report_helper).to receive(:get_default_template)
          allow(dummy_pdftk).to receive(:fill_form).and_raise StandardError

          post '/api/v1/create/pdf/', params

          expect(last_response.status).to eq 422
        end
      end
    end
  end

  describe '#download' do
    context 'when the report does not exist' do
      it 'expects a 404 not found status code' do
        allow(dummy_report_helper).to receive(:get_report).and_return(nil)
        get 'api/v1/download/report_name/year/npwd'
        expect(last_response.status).to eq 404
      end
    end

    context 'when file does exist' do
      it 'expects a 200 status code' do
        File.open('temp/out.txt', 'w+') do |f|
          f.write('data_you_want_to_write')
        end
        response = { response_body: 'sagag', target: 'temp/out.txt' }
        allow(dummy_report_helper).to receive(:get_report).and_return(response)
        get 'api/v1/download/report_name/year/npwd'
        expect(last_response.status).to eq 200
        `rm temp/out.txt`
      end
    end
  end
  describe '#form_fields' do
    let(:fields) do
      {
        field1: {
          name: 'field_name1',
          type: 'Button',
          flags: 'flag1',
          justification: 'left',
          value: 'field.value',
          options: { a: 'b' }
        },
        field2: {
            name: 'field_name1',
            type: 'Text',
            flags: 'flag1',
            justification: 'left',
            value: 'field.value',
            options: { a: 'b' }
        }
      }

    end
    context 'when the report does not exist' do
      it 'expects a 404 not found status code' do
        allow(dummy_pdftk).to receive(:get_fields).and_return({})
        get 'api/v1/form_fields/report_name'
        expect(last_response.status).to eq 404
      end
    end

    context 'when file does exist' do
      it 'expects a 200 status code' do
        File.open('temp/out.txt', 'w+') do |f|
          f.write('data_you_want_to_write')
        end
        response = {}
        allow(dummy_pdftk).to receive(:get_fields).and_return(fields)

        allow_any_instance_of(PdfServer).to receive(:extract_fields).and_return(fields)
        get 'api/v1/form_fields/report_name'
        expect(last_response.status).to eq 200
        `rm temp/out.txt`
      end
    end
  end
end