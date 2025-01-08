# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../models/recipe'
require_relative '../../services/validate_recipe_service'

describe ValidateRecipeService do
  describe 'ancestors' do
    it 'inherits from BaseAnthropicService' do
      expect(described_class.ancestors).to include(BaseAnthropicService)
    end
  end

  subject { described_class.new(recipe) }

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
          "text"=>claude_response
        }
      ],
      "stop_reason"=>"end_turn",
      "stop_sequence"=>nil,
      "usage"=>{
        "input_tokens"=>10, "cache_creation_input_tokens"=>0, "cache_read_input_tokens"=>0, "output_tokens"=>18
      }
    }
  end
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

  before do
    allow(Anthropic::Client).to receive(:new).with(
      access_token: 'ANTHROPIC_API_TEST_KEY',
      anthropic_version: BaseAnthropicService::ANTHROPIC_VERSION
    ).and_return(anthropic_client)
  end

  describe '#prompt' do
    it 'returns proper prompt from recipe' do
      expect(subject.send(:prompt)).to eq(
        <<~PROMPT
          I have potential recipe for a meal presented as a JSON object.#{' '}
          JSON object contains keys such as: #{Recipe.attribute_names.join(', ')}.
          Validate if it is really a recipe. Respond with JSON schema: { valid: boolean }.
          Only respond with JSON. Under valid key, provide true or false. True for valid recipe, false for invalid recipe.
          Input JSON: #{recipe.to_json}
        PROMPT
      )
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

    context 'valid recipe' do
      let(:claude_response) { { "valid" => true }.to_json }

      before do
        expect(Retryable).to receive(:retryable).with(tries: 3, not: [ BaseAnthropicService::ClaudeConnectionError ]).and_call_original
        expect(Retryable).to receive(:retryable).with(tries: 3, on: [ Faraday::Error ]).and_call_original
        expect(anthropic_client).to receive(:messages).with(anthropic_request_params).and_return(anthropic_response)
      end

      it 'returns true' do
        expect(subject.call).to eq(true)
      end
    end

    context 'invalid recipe' do
      context 'on model level' do
        let(:recipe) { Recipe.new(ingredients: "bad format") }

        before do
          expect(Anthropic::Client).to_not receive(:new)
          expect(anthropic_client).to_not receive(:messages)
        end

        it 'returns false' do
          expect(subject.call).to eq(false)
        end
      end

      context 'on instructions level that needs to be checked with anthropic' do
        before do
          expect(Retryable).to receive(:retryable).with(tries: 3, not: [ BaseAnthropicService::ClaudeConnectionError ]).and_call_original
          expect(Retryable).to receive(:retryable).with(tries: 3, on: [ Faraday::Error ]).and_call_original
          expect(anthropic_client).to receive(:messages).with(anthropic_request_params).and_return(anthropic_response)
        end

        context 'proper response format' do
          let(:claude_response) { { "valid" => false }.to_json }
          it 'returns false' do
            expect(subject.call).to eq(false)
          end
        end

        context 'handles invalid response format gracefully' do
          let(:claude_response) { "invalid json" }
          it 'returns false' do
            expect(subject.call).to eq(false)
          end
        end
      end

      context 'anthropic api responds with an error' do
        it "passes error further" do
          expect(anthropic_client).to receive(:messages).and_raise(Faraday::Error)
          expect { subject.call }.to raise_error(BaseAnthropicService::ClaudeConnectionError)
        end
      end
    end
  end
end
