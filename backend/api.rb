# frozen_string_literal: true

require 'grape'
require_relative 'v1/recipes'

class API < Grape::API
  prefix :api

  mount V1::Recipes
end
