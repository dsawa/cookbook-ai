require 'retryable'
require_relative './base_anthropic_service'
require_relative '../models/recipe'

class CreateRecipeService < BaseAnthropicService
  Error = Class.new(StandardError)

  attr_reader :ingredients, :logger

  def initialize(ingredients, logger: nil)
    @ingredients = ingredients
    @logger = logger
  end

  def call
    Retryable.retryable(tries: 3, not: [ Faraday::Error ]) do
      logger&.info("Asking Claude for recipe with: #{ingredients}")
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
    message = "Could not parse response: #{e.message}"
    logger&.error(message)
    raise Error, message
  end
end
