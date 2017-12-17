class PwprClient
  BUSINESS_SHOW_ENDPOINT = "api/v1/businesses/".freeze

  def initialise
  end

  def get_request(url, id)
    uri = URI.parse("api/v1/businesses/#{id}")
    Net::HTTP.start(uri.host, uri.port, params) do |http|
      request = Net::HTTP::Get.new uri.request_uri
      request.basic_auth 'pdf_server', '435jhadsfgkuy9863234ertfgjkljgkasdtigkkjfhjkdh'
      response = http.request request # Net::HTTPResponse object
      puts response
      puts response.body
    end
  end
end
