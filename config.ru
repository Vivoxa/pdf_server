$: << File.dirname(__FILE__)
#\ -s puma
require 'load_dependencies'
run PdfServer.new
