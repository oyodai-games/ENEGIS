# frozen_string_literal: true

require 'yaml'
require 'openai'

# ユーザー入力を元に、ChatGPT APIでテキスト・画像を生成する機能を提供する。
class ChatGptApi
  # 初期化メソッド。プロンプト文、GPTの設定リスト、検証関数リストを受け取る
  #
  # @param settings [Hash] GPT設定を含むハッシュ(モデルなど)
  def initialize(settings_list)
    @model = settings_list['model']
    @temperature = settings_list['temperature']
    @top_p = settings_list['top_p']
    @n = settings_list['n']
    @stream = settings_list['stream']
    @max_tokens = settings_list['max_tokens']
    @presence_penalty = settings_list['presence_penalty']
    @frequency_penalty = settings_list['frequency_penalty']

    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  # プロンプト文に基づきテキストを生成し、検証を行う
  #
  # @param prompts [Hash] テキスト生成のプロンプト文
  # @param validators [Array<Object>] 出力を検証するための関数リスト
  # @return [Hash, nil] 生成されたテキストのハッシュ
  def generate_text(prompts, validators)
    # ChatGPT APIを呼び出す
    response = call_chat_gpt_api(prompts)

    # JSON形式をハッシュに変換
    response = JsonUtils.json_to_hash(response['choices'][0]['message']['content'])
    return nil if response.nil?

    # 生成されたテキスト(辞書型)を検証
    validators.each do |validator|
      unless validator.call(response)
        Rails.logger.error "Validation failed: #{response}"
        return nil
      end
    end

    response
  rescue ChatGptApiError => e
    Rails.logger.error "ChatGptApiError occurred: #{e.message}"
    raise e
  rescue StandardError => e
    Rails.logger.error "Unexpected error: #{e.message}"
    raise ChatGptApiError.new('Unexpected error occurred', 500, 1004)
  end

  # GPT APIを呼び出し、テキストを生成するメソッド
  #
  # @param prompts [Hash] プロンプト文
  # @return [String] 生成されたテキスト
  def call_chat_gpt_api(prompts)
    @client.chat(
      parameters: {
        model: @model,
        temperature: @temperature,
        top_p: @top_p,
        n: @n,
        stream: @stream,
        max_tokens: @max_tokens,
        presence_penalty: @presence_penalty,
        frequency_penalty: @frequency_penalty,
        messages: [
          { role: 'system', content: prompts['system'] },
          { role: 'user', content: prompts['user'] }
        ]
      }
    )
  rescue OpenAI::Error => e
    Rails.logger.error "ChatGPT API call failed: #{e.message}"
    raise ChatGptApiCallError, e.message
  rescue Faraday::UnauthorizedError => e
    Rails.logger.error "ChatGPT API call failed: #{e.message}"
    raise ChatGptApiCallError, e.message
  end

  def self.create_prompts(path, user_input)
    yaml_data = YAML.load_file(path)
    raise FileNotFoundError, path unless yaml_data['prompt']

    { 'system' => yaml_data['prompt'], 'user' => user_input }
  rescue Errno::ENOENT
    raise FileNotFoundError, path
  rescue Psych::SyntaxError => e
    raise InvalidYamlError, e.message
  rescue StandardError => e
    Rails.logger.error "Unexpected error while loading YAML: #{e.message}"
    raise ChatGptApiError.new('YAML parsing failed', 500, 1005)
  end
end
