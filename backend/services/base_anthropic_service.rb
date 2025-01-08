require 'anthropic'
require 'retryable'

class BaseAnthropicService
  ANTHROPIC_MAX_TOKENS = 1024.freeze
  ANTHROPIC_VERSION = "2023-06-01".freeze
  ANTHROPIC_MODEL = "claude-3-5-sonnet-20241022".freeze

  def call
    raise NotImplementedError, "Implement method in child class"
  end

  protected

  def ask_claude
    raise ArgumentError, "Prompt cannot be blank" if prompt.nil? || prompt.empty?

    Retryable.retryable(tries: 3, on: [ Faraday::Error ]) do
      anthropic_client.messages(
        parameters: {
          model: ANTHROPIC_MODEL,
          system: "You are an API client of a chef master. Respond only using JSON format.",
          messages: [
            {
              role: "user",
              content: prompt
            }
          ],
          max_tokens: ANTHROPIC_MAX_TOKENS
        }
      )
    end
  end

  def prompt
    raise NotImplementedError, "Implement method in child class"
  end

  private

  def anthropic_client
    @anthropic_client ||= Anthropic::Client.new(
      access_token: ENV.fetch('ANTHROPIC_API_KEY'),
      anthropic_version: ANTHROPIC_VERSION
    )
  end
end
