require 'active_model'

class Recipe
  include ActiveModel::API
  include ActiveModel::Attributes
  include ActiveModel::Serializers::JSON

  attribute :title, :string
  attribute :description, :string
  attribute :time, :string
  attribute :serves, :string
  attribute :difficulty, :string
  attribute :ingredients
  attribute :steps

  validates :title, :description, :ingredients, :steps, :time, :serves, :difficulty, presence: true
  validate :ingredients_is_array
  validate :steps_is_array

  private

  def ingredients_is_array
    validate_array(:ingredients, ingredients)
  end

  def steps_is_array
    validate_array(:steps, steps)
  end

  def validate_array(key, value)
    errors.add(key, "must be an array") unless value.is_a?(Array)
  end
end
