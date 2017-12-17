class PdfServer < Sinatra::Base
  register Sinatra::Namespace

  SERVER_TMP_FILE_DIR = 'public'.freeze
  DEFAULT_FILE_EXT = 'pdf'.freeze
  TMP_FILEPATH = 'public/filetest.pdf'.freeze
  PDFTK_LIB_LOCATION = ENV.fetch('PDFTK_LOCATION', '/usr/bin/pdftk')

  use Rack::Auth::Basic, "Restricted Area" do |app_name, api_key|
    app_name == 'pwpr_app' and api_key == ENV.fetch('PWPR_API_KEY')
  end

  namespace '/api/v1' do

    get '/business/:id' do |id|
      require 'pry'
      uri = URI.parse("http://pwpr_app:3000/api/v1/businesses/#{id}")
      Net::HTTP.start(uri.host, uri.port, params) do |http|
        request = Net::HTTP::Get.new uri.request_uri
        request.basic_auth 'pdf_server', '435jhadsfgkuy9863234ertfgjkljgkasdtigkkjfhjkdh'
        response = http.request request # Net::HTTPResponse object
        puts response
        puts response.body
      end
    end

    post '/create/pdf/' do
      values = JSON.parse(params['values'])
      year = params['year']
      business_npwd = params['business_npwd']
      report_type = params['report_type']

      file_location = tmp_filename(year, business_npwd, report_type)
      pdftk.fill_form(s3_helper.get_default_template(report_type), file_location, values)

      s3_helper.upload_to_S3(year, business_npwd, report_type, file_location)
      cleanup
    end

    get '/download/:filename' do |filename|
      'Downloads'
      send_file "public/#{filename}", :filename => filename, :type => 'Application/octet-stream'
    end

    get '/form_fields/:report_type' do |report_type|
      content_type :json
      template = s3_helper.get_default_template(report_type)

      pdf_fields = pdftk.get_fields(template)
      json_fields = extract_fields(pdf_fields).to_json
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

  def cleanup
    FileUtils.rm [TMP_FILEPATH], force: true
  end

  private

  def s3_helper()
    @s3_helper ||= S3Helper.new
  end

  def tmp_filename(year, business_npwd, report_type, ext = DEFAULT_FILE_EXT)
    "#{SERVER_TMP_FILE_DIR}/#{report_type}_#{year}_#{business_npwd}.#{ext}"
  end

  def environment()
    ENV.fetch('ENV', 'development')
  end
end
