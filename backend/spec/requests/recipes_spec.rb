require_relative '../spec_helper'
require_relative '../../v1/recipes'

describe V1::Recipes, type: :request do
  include Rack::Test::Methods

  def app
    V1::Recipes
  end

  before do
    allow(app).to receive(:logger).and_return(Logger.new('/dev/null'))
    header 'Authorization', "Bearer #{token}"
  end

  describe 'POST /v1/recipes' do
    let(:ingredients) { [ 'chicken', 'rice' ] }
    let(:params) { { ingredients: ingredients } }

    context 'when is missing' do
      let(:token) { nil }

      it 'returns 401 status' do
        post '/v1/recipes', params: params
        expect(last_response.status).to eq(401)
      end

      it 'returns json with error message' do
        post '/v1/recipes', params: params

        json_response = JSON.parse(last_response.body)
        expect(json_response).to eq({ 'error' => '401 Unauthorized' })
      end
    end

    context 'when token is invalid' do
      let(:token) { 'invalid-token' }

      it 'returns 401 status' do
        post '/v1/recipes', params: params
        expect(last_response.status).to eq(401)
      end

      it 'returns json with error message' do
        post '/v1/recipes', params: params

        json_response = JSON.parse(last_response.body)
        expect(json_response).to eq({ 'error' => '401 Unauthorized' })
      end
    end

    context 'when token is valid' do
      let(:token) { 'Test' }

      context 'when ingredients are missing' do
        it 'returns 400 status' do
          post '/v1/recipes', params: {}
          expect(last_response.status).to eq(400)
        end

        it 'returns json with error message' do
          post '/v1/recipes', params: params

          json_response = JSON.parse(last_response.body)
          expect(json_response['title']).to eq('Ingredients cannot be blank')
          expect(json_response['status']).to eq(400)
          expect(json_response['detail']).to eq('Ingredients cannot be blank')
        end
      end

      context 'when ingredients are empty' do
        let(:ingredients) { [] }
        let(:params) { { ingredients: ingredients } }

        it 'returns 400 status' do
          post '/v1/recipes', params: params
          expect(last_response.status).to eq(400)
        end

        it 'returns json with error message' do
          post '/v1/recipes', params: params

          json_response = JSON.parse(last_response.body)
          expect(json_response['title']).to eq('Ingredients cannot be blank')
          expect(json_response['status']).to eq(400)
          expect(json_response['detail']).to eq('Ingredients cannot be blank')
        end
      end
    end
  end
end
