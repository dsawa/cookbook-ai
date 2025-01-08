# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../services/base_anthropic_service'

class TestService < BaseAnthropicService
  def call
    ask_claude
  end

  def prompt
    "Hello Claude!"
  end
end

describe BaseAnthropicService do
  subject { TestService.new }

  let(:prompt) { "Hello Claude!" }
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
          "text"=>"Hello! How can I help you today?"
        }
      ],
      "stop_reason"=>"end_turn",
      "stop_sequence"=>nil,
      "usage"=>{
        "input_tokens"=>10, "cache_creation_input_tokens"=>0, "cache_read_input_tokens"=>0, "output_tokens"=>18
      }
    }
  end

  before do
    allow(Anthropic::Client).to receive(:new).with(
      access_token: 'ANTHROPIC_API_TEST_KEY',
      anthropic_version: BaseAnthropicService::ANTHROPIC_VERSION
    ).and_return(anthropic_client)
  end

  describe '#ask_claude' do
    context 'prompt is blank' do
      [ nil, '' ].each do |value|
        it "raises an ArgumentError if #{value}" do
          expect(subject).to receive(:prompt).at_least(:once).and_return(value)
          expect { subject.call }.to raise_error(ArgumentError, "Prompt cannot be blank")
        end
      end
    end

    context 'anthropic api responds successfully' do
      it "calls messages on anthropic client with proper parameters" do
        expect(anthropic_client).to receive(:messages).with(
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
        ).and_return(anthropic_response)

        subject.call
      end
    end

    context 'anthropic api responds with an error' do
      it "retries the request 3 times" do
        expect(Retryable).to receive(:retryable).with(tries: 3, on: [ Faraday::Error ]).and_call_original
        expect(anthropic_client).to receive(:messages).and_raise(Faraday::Error)
        expect { subject.call }.to raise_error(Faraday::Error)
      end
    end
  end
end
