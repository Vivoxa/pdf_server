$: << File.dirname(__FILE__)
require 'route_handlers/pdf_server'
run PdfServer.new
