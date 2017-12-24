module AuthHelper
  def http_login
    spoof_env_vars
    user = 'pwpr_app'
    pw = 'api_key'
    basic_authorize(user, pw)
  end

  def spoof_env_vars
    allow(ENV).to receive(:fetch).with('PWPR_API_KEY').and_return('api_key')
    allow(ENV).to receive(:fetch).with('SERVICE_NAME').and_return('pdf_server')
  end
end
