require 'rack/cors'
require 'debug' if ENV['RACK_ENV'] == 'development'
require_relative 'api'

use Rack::Cors do
  allow do
    origins ENV.fetch('CORS_DOMAINS', '*')
    resource '/api/*',
      headers: :any,
      methods: [ :get, :post, :options ],
      expose: [ 'Content-Type' ]
  end
end

run API
