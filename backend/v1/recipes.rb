module V1
  class Recipes < Grape::API
    format :json
    version 'v1'

    get '/ping' do
      { message: 'pong' }
    end
  end
end