# frozen_string_literal: true

require_relative '../services/create_recipe_service'
require_relative '../services/validate_recipe_service'

module V1
  class Recipes < Grape::API
    format :json
    version 'v1'

    helpers do
      def logger
        Recipes.logger
      end

      def authenticate!
        auth_header = headers['Authorization']
        token = auth_header&.match(/^Bearer (.+)$/)&.[](1)
        allowed_tokens = ENV['ALLOWED_API_TOKENS'].split(',')

        return if token && allowed_tokens.include?(token)

        error!('401 Unauthorized', 401)
      end
    end

    get '/ping' do
      { message: 'pong' }
    end

    post '/recipes' do
      authenticate!

      params do
        requires :ingredients, type: Array[String]
      end

      recipe = CreateRecipeService.new(params[:ingredients], logger:).call

      if ValidateRecipeService.new(recipe, logger:).call
        recipe.as_json
      else
        details = recipe.errors.full_messages.join(", ")
        logger.error("Could not create recipe: #{details}")
        status 400

        {
          title: "Could not create recipe. Try again.",
          status: 400,
          detail: details,
          errors: recipe.errors
        }
      end
    rescue CreateRecipeService::InvalidIngredientsError => e
      status 400
      { title: e.message, status: 400, detail: e.message }
    rescue CreateRecipeService::Error => e
      logger.error("Recipe creation failed #{e.class}: #{e.message}")
      status 500
      { title: 'Internal Server Error', status: 500 }
    end
  end
end
