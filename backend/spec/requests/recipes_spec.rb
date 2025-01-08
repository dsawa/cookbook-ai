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
        post '/v1/recipes', params
        expect(last_response.status).to eq(401)
      end

      it 'returns json with error message' do
        post '/v1/recipes', params

        json_response = JSON.parse(last_response.body)
        expect(json_response).to eq({ 'error' => '401 Unauthorized' })
      end
    end

    context 'when token is invalid' do
      let(:token) { 'invalid-token' }

      it 'returns 401 status' do
        post '/v1/recipes', params
        expect(last_response.status).to eq(401)
      end

      it 'returns json with error message' do
        post '/v1/recipes', params

        json_response = JSON.parse(last_response.body)
        expect(json_response).to eq({ 'error' => '401 Unauthorized' })
      end
    end

    context 'when token is valid' do
      let(:token) { 'Test' }
      let(:recipe) do
        Recipe.new(
          title: "Simple Sweet Pancakes",
          description: "Light and fluffy pancakes made with basic ingredients",
          ingredients: [
            "2 cups of flour",
            "3 tablespoons of sugar",
            "100g melted butter",
            "2 cups of milk"
          ],
          steps: [
            "Mix flour and sugar in a large bowl",
            "Warm up the milk slightly and melt the butter",
            "Gradually add milk to the dry ingredients while whisking",
            "Add melted butter and mix until smooth",
            "Heat a non-stick pan over medium heat",
            "Pour about 1/4 cup of batter for each pancake",
            "Cook until bubbles form on surface, then flip",
            "Cook other side until golden brown"
          ],
          time: "30 minutes",
          serves: "4 people",
          difficulty: "easy"
        )
      end
      let(:create_service) { instance_double(CreateRecipeService) }
      let(:validate_service) { instance_double(ValidateRecipeService) }

      context 'when recipe creation succeeds' do
        before do
          expect(CreateRecipeService).to receive(:new).with(ingredients, logger: app.logger).and_return(create_service)
          expect(create_service).to receive(:call).and_return(recipe)
        end

        context 'when recipe validation succeeds' do
          before do
            expect(ValidateRecipeService).to receive(:new).with(recipe, logger: app.logger).and_return(validate_service)
            expect(validate_service).to receive(:call).and_return(true)
          end

          it 'returns 200 status' do
            post '/v1/recipes', params
            expect(last_response.status).to eq(201)
          end

          it 'returns json with recipe' do
            post '/v1/recipes', params

            json_response = JSON.parse(last_response.body)
            expect(json_response).to eq(recipe.as_json)
          end
        end

        context 'when recipe validation fails' do
          before do
            expect(ValidateRecipeService).to receive(:new).with(recipe, logger: app.logger).and_return(validate_service)
            expect(validate_service).to receive(:call).and_return(false)
          end

          it 'returns 400 status' do
            post '/v1/recipes', params
            expect(last_response.status).to eq(400)
          end

          it 'returns error json' do
            post '/v1/recipes', params

            json_response = JSON.parse(last_response.body)
            expect(json_response['title']).to eq('Could not create recipe. Try again.')
            expect(json_response['status']).to eq(400)
          end
        end
      end

      context 'when recipe creation fails because of anhtropic connection or bad response' do
        before do
          expect(CreateRecipeService).to receive(:new)
          .with(ingredients, logger: app.logger)
          .and_raise(CreateRecipeService::Error, 'Could not parse response: invalid JSON')
        end

        it 'returns 500 status' do
          post '/v1/recipes', params
          expect(last_response.status).to eq(500)
        end

        it 'returns error json' do
          post '/v1/recipes', params

          json_response = JSON.parse(last_response.body)
          expect(json_response['title']).to eq('Internal Server Error')
          expect(json_response['status']).to eq(500)
        end
      end

      context "when ingredients are missing" do
        [ {}, { ingredients: [] } ].each do |invalid_params|
          context "when params are #{invalid_params}" do
            it 'returns 400 status' do
              post '/v1/recipes', {}
              expect(last_response.status).to eq(400)
            end

            it 'returns json with error message' do
              post '/v1/recipes', {}

              json_response = JSON.parse(last_response.body)
              expect(json_response['title']).to eq('Ingredients cannot be blank')
              expect(json_response['status']).to eq(400)
              expect(json_response['detail']).to eq('Ingredients cannot be blank')
            end
          end
        end
      end
    end
  end
end
