require 'sinatra/base'
require 'sinatra/namespace'
require 'json'
require 'pdf-forms'
require 'aws_gateway'
require 'net/http'
require 'uri'
require 'route_handlers/pdf_server'
require 'lib/pwpr_client'