require 'sinatra/base'
class PdfServer < Sinatra::Base
  get '/' do
    'Welcome to PDF server'
  end
end
