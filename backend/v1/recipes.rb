# frozen_string_literal: true

require_relative '../services/create_recipe_service'
require_relative '../services/recipe_validate_service'

module V1
  class Recipes < Grape::API
    format :json
    version 'v1'

    get '/ping' do
      { message: 'pong' }
    end

    post '/recipes' do
      params do
        requires :ingredients, type: Array[String]
      end

      recipe = CreateRecipeService.new(params[:ingredients]).call

      if RecipeValidateService.new(recipe).call
        recipe.as_json
      else
        {
          title: "Could not create recipe. Try again.",
          status: 400,
          detail: recipe.errors.full_messages.join(", "),
          errors: recipe.errors
         }
      end
    end
  end
end
