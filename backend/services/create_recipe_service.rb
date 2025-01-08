require 'retryable'
require_relative './base_anthropic_service'
require_relative '../models/recipe'

class CreateRecipeService < BaseAnthropicService
  Error = Class.new(StandardError)

  attr_reader :ingredients

  def initialize(ingredients)
    @ingredients = ingredients
  end

  def call
    Retryable.retryable(tries: 3, not: [ Faraday::Error ]) do
      response = ask_claude
      build_recipe(response)
    end
  end

  protected

  def prompt
    raise ArgumentError, "Ingredients cannot be blank" if ingredients.nil? || ingredients.empty?

    <<~PROMPT
      I have #{ingredients}. Please provide me a recipe using these ingredients.
      Answer in the provided JSON format. Only include JSON.
      JSON schema should be: {title: string, description: string, ingredients: strings, steps: [strings], time: string, serves: string, difficulty: string}
    PROMPT
  end

  private

  def build_recipe(response)
    content = response.dig("content", 0, "text")
    parsed = JSON.parse(content)

    Recipe.new(parsed)
  rescue JSON::ParserError, ArgumentError => e
    raise Error, "Could not parse response: #{e.message}"
  end
end
