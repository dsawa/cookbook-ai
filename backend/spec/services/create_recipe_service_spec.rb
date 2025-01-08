# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../models/recipe'
require_relative '../../services/create_recipe_service'

describe CreateRecipeService do
  describe 'ancestors' do
    it 'inherits from BaseAnthropicService' do
      expect(described_class.ancestors).to include(BaseAnthropicService)
    end
  end
  subject { described_class.new(ingredients) }

  let(:ingredients) { %w[flour sugar butter milk] }
  let(:anthropic_client) { instance_double(Anthropic::Client) }
  let(:anthropic_response) do
    {
      "id"=>"msg_01BV4VBYNYW6KyPKCYxKMktA",
      "type"=>"message",
      "role"=>"assistant",
      "model"=>BaseAnthropicService::ANTHROPIC_MODEL,
      "content"=> [
        {
          "type"=>"text",
          "text"=>claude_response.to_json
        }
      ],
      "stop_reason"=>"end_turn",
      "stop_sequence"=>nil,
      "usage"=>{
        "input_tokens"=>10, "cache_creation_input_tokens"=>0, "cache_read_input_tokens"=>0, "output_tokens"=>18
      }
    }
  end
  let(:claude_response) do
    {
      "title" => "Simple Sweet Pancakes",
      "description" => "Light and fluffy pancakes made with basic ingredients",
      "ingredients" => [
        "2 cups of flour",
        "3 tablespoons of sugar",
        "100g melted butter",
        "2 cups of milk"
      ],
      "steps" => [
        "Mix flour and sugar in a large bowl",
        "Warm up the milk slightly and melt the butter",
        "Gradually add milk to the dry ingredients while whisking",
        "Add melted butter and mix until smooth",
        "Heat a non-stick pan over medium heat",
        "Pour about 1/4 cup of batter for each pancake",
        "Cook until bubbles form on surface, then flip",
        "Cook other side until golden brown"
      ],
      "time" => "30 minutes",
      "serves" => "4 people",
      "difficulty" => "easy"
    }
  end

  before do
    allow(Anthropic::Client).to receive(:new).with(
      access_token: 'ANTHROPIC_API_TEST_KEY',
      anthropic_version: BaseAnthropicService::ANTHROPIC_VERSION
    ).and_return(anthropic_client)
  end

  describe '#prompt' do
    context 'valid ingredients' do
      it 'returns proper prompt from ingredients' do
        expect(subject.send(:prompt)).to eq(
          <<~PROMPT
            I have #{ingredients}. Please provide me a recipe using these ingredients.
            Answer in the provided JSON format. Only include JSON.
            JSON schema should be: {title: string, description: string, ingredients: strings, steps: [strings], time: string, serves: string, difficulty: string}
          PROMPT
        )
      end
    end

    context 'invalid ingredients' do
      [ nil, "", [ '' ] ].each do |value|
        let(:ingredients) { value }
        it "raises InvalidIngredientsError if ingredients are #{value}" do
          expect { subject.send(:prompt) }.to raise_error(CreateRecipeService::InvalidIngredientsError, "Ingredients cannot be blank")
        end
      end
    end
  end

  describe '#call' do
    let(:prompt) { subject.send(:prompt) }
    let(:anthropic_request_params) do
        {
          parameters: {
          model: BaseAnthropicService::ANTHROPIC_MODEL,
          system: "You are an API client of a chef master. Respond only using JSON format.",
          messages: [
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: BaseAnthropicService::ANTHROPIC_MAX_TOKENS
        }
      }
    end

    context 'anthropic api responds with an error' do
      it "passes raises internal error to gracefully return 500" do
        expect(Retryable).to receive(:retryable).with(tries: 3, not: [ Faraday::Error ]).and_call_original
        expect(Retryable).to receive(:retryable).with(tries: 3, on: [ Faraday::Error ]).and_call_original
        expect(anthropic_client).to receive(:messages).and_raise(Faraday::Error)
        expect { subject.call }.to raise_error(CreateRecipeService::Error)
      end
    end

    context 'no error on api' do
      before do
        expect(anthropic_client).to receive(:messages).with(anthropic_request_params).and_return(anthropic_response)
      end

      context 'claude returns proper recipe' do
        let(:recipe_title) { claude_response["title"] }
        let(:recipe_description) { claude_response["description"] }
        let(:recipe_ingredients) { claude_response["ingredients"] }
        let(:recipe_steps) { claude_response["steps"] }
        let(:recipe_time) { claude_response["time"] }
        let(:recipe_serves) { claude_response["serves"] }
        let(:recipe_difficulty) { claude_response["difficulty"] }

        it 'recipe instance' do
          recipe = subject.call

          expect(recipe).to be_instance_of(Recipe)
          expect(recipe.title).to eq(recipe_title)
          expect(recipe.description).to eq(recipe_description)
          expect(recipe.ingredients).to eq(recipe_ingredients)
          expect(recipe.steps).to eq(recipe_steps)
          expect(recipe.time).to eq(recipe_time)
          expect(recipe.serves).to eq(recipe_serves)
          expect(recipe.difficulty).to eq(recipe_difficulty)
        end
      end

      context 'passes invalid response format gracefully' do
        [ nil, "some text" ].each do |value|
          let(:claude_response) { value }
          it 'passes error further after tryouts' do
            expect(Retryable).to receive(:retryable).with(tries: 3, not: [ Faraday::Error ]).and_call_original
            expect(Retryable).to receive(:retryable).with(tries: 3, on: [ Faraday::Error ]).and_call_original
            expect { subject.call }.to raise_error(CreateRecipeService::Error, /Could not parse response/)
          end
        end
      end
    end
  end
end
