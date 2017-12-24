# frozen_string_literal: true

# facilitates pdf generation and manipulation
class PdfServer < Sinatra::Base
  register Sinatra::Namespace

  SERVER_TMP_FILE_DIR = 'temp'
  DEFAULT_FILE_EXT = 'pdf'
  PDFTK_LIB_LOCATION = ENV.fetch('PDFTK_LOCATION', '/usr/bin/pdftk')
  APP_NAME = 'pwpr_app'

  use Rack::Auth::Basic, "Restricted Area" do |app_name, api_key|
    app_name == APP_NAME and api_key == ENV.fetch('PWPR_API_KEY')
  end

  namespace '/api/v1' do

    post '/create/pdf/' do
      values = JSON.parse(params['values'])
      year = params['year']
      business_npwd = params['business_npwd']
      report_type = params['report_type']

      file_location = tmp_filename(year, business_npwd, report_type)

      result = s3_report_helper.get_default_template(report_type)

      pdftk.fill_form(result[:response_body], file_location, values)

      s3_report_helper.upload_to_S3(year, business_npwd, report_type, file_location)

      cleanup(file_location)
    end

    get '/download/:report_name/:year/:npwd' do |npwd, year, report_name|
      resp = s3_report_helper.get_report(year, npwd, report_name)
      send_file resp[:target], filename: resp[:target], type: 'Application/octet-stream'
    end

    get '/form_fields/:report_type' do |report_type|
      content_type :json
      result = s3_report_helper.get_default_template(report_type)

      pdf_fields = pdftk.get_fields(result[:response_body])
      json_fields = extract_fields(pdf_fields).to_json
      cleanup(result[:target])
      if json_fields
        status 200
        json_fields
      else
        status 404
      end
    end
  end

  def pdftk
    @pdftk ||= PdfForms.new(PDFTK_LIB_LOCATION)
  end

  def extract_fields(pdftk_fields)
    fields = {}
    pdftk_fields.each do |field|
      if (field.type == "Button")
        fields[field.name] = {
            name: field.name,
            type: field.type,
            flags: field.flags,
            justification: field.justification,
            value: field.value,
            options: field.options
        }
      end
      if (field.type == "Text")
        fields[field.name] = {
            name: field.name,
            type: field.type,
            flags: field.flags,
            justification: field.justification,
            value: field.value,
            max_length: field.max_length
        }
      end
    end
    fields
  end

  def cleanup(filename)
    FileUtils.rm [filename], force: true
  end

  private

  def s3_report_helper
    @s3_report_helper ||= S3ReportHelper.new(SERVER_TMP_FILE_DIR)
  end

  def tmp_filename(year, business_npwd, report_type, ext = DEFAULT_FILE_EXT)
    "#{SERVER_TMP_FILE_DIR}/#{report_type}_#{year}_#{business_npwd}.#{ext}"
  end

  def environment()
    ENV.fetch('ENV', 'development')
  end
end
