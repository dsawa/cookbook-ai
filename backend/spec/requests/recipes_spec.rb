require_relative '../spec_helper'
require_relative '../../v1/recipes'

describe V1::Recipes, type: :request do
  include Rack::Test::Methods

  def app
    V1::Recipes
  end

  let(:valid_token) { 'Test' }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'POST /v1/recipes' do
    let(:ingredients) { [ 'chicken', 'rice' ] }
    let(:params) { { ingredients: ingredients } }

    context 'when is missing' do
      let(:token) { nil }

      it 'returns 401 status' do
        post '/v1/recipes', params: params, headers: headers
        expect(last_response.status).to eq(401)
      end
    end

    context 'when token is invalid' do
      let(:token) { 'invalid-token' }

      it 'returns 401 status' do
        post '/v1/recipes', params: params, headers: headers
        expect(last_response.status).to eq(401)
      end
    end
  end
end
