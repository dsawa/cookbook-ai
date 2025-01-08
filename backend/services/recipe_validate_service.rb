require_relative './base_anthropic_service'

class RecipeValidateService < BaseAnthropicService
  attr_reader :recipe, :logger

  def initialize(recipe, logger: nil)
    @recipe = recipe
    @logger = logger
  end

  def call
    return false unless recipe.valid?

    logger&.info("Asking Claude to validate recipe..")
    response = ask_claude
    answer = response.dig("content", 0, "text")&.downcase
    answer_parsed = JSON.parse(answer)

    return true if answer_parsed["valid"]

    logger&.error("Recipe is not valid: #{recipe.as_json}")
    recipe.errors.add(:base, "Recipe is not valid")
    false
  rescue JSON::ParserError
    logger&.error("Could not parse Claude response on validation: #{response.inspect}")
    recipe.errors.add(:base, "Couldn't check if recipe is valid. Probably invalid")
    false
  end

  protected

  def prompt
    <<~PROMPT
      I have potential recipe for a meal presented as a JSON object.#{' '}
      JSON object contains keys such as: #{Recipe.attribute_names.join(', ')}.
      Validate if it is really a recipe. Respond with JSON schema: { valid: boolean }.
      Only respond with JSON. Under valid key, provide true or false. True for valid recipe, false for invalid recipe.
      Input JSON: #{recipe.to_json}
    PROMPT
  end
end
