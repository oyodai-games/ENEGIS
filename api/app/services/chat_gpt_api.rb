# frozen_string_literal: true

require 'erb'
require 'yaml'
require 'async'
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
    @max_create = settings_list['max_create']
    @max_failed_access = settings_list['max_failed_access']
    @time_to_access_refresh = settings_list['time_to_access_refresh']

    @client = OpenAI::Client.new(access_token: ENV['OPENAI_ACCESS_TOKEN'])
  end

  # プロンプト文に基づきテキストを生成し、検証を行う
  #
  # @param prompts [Hash] テキスト生成のプロンプト文
  # @param validators [Array<Object>] 出力を検証するための関数リスト
  # @return [Hash, nil] 生成されたテキストのハッシュ
  def generate_text(prompts, validators)
    generate_count = 0
    count_failed_access = 0

    loop do
      # ChatGPT APIを呼び出す
      async_task = call_chat_gpt_api(prompts)
      generate_count += 1
      response = async_task.wait

      response_hash = parse_response_to_hash(response)

      # 検証に成功した場合、returnする
      return response_hash if validates(validators, response_hash)

      # 生成回数が上限に達した場合に終了
      check_generate_count(generate_count, response_hash, prompts)
    rescue Faraday::ConnectionFailed => e
      # アクセスに失敗した回数が上限に達した場合に終了
      Rails.logger.error "Authorization failed, retrying after #{@time_to_access_refresh} seconds: #{e.message}"
      count_failed_access += 1
      raise e unless count_failed_access < @max_failed_access

      # 非同期で指定秒数待機した後、loopの先頭からやり直す
      Async do |task|
        task.sleep(@time_to_access_refresh)
      end.wait
      retry
    rescue JSON::ParserError => e
      # 生成回数が上限に達した場合に終了
      check_generate_count(generate_count, response_hash, prompts)
      retry
    end
  end

  # GPT APIを呼び出し、テキストを生成するメソッド
  #
  # @param prompts [Hash] プロンプト文
  # @return [Async::Task] 生成されたテキスト
  #
  # @raise [Faraday::ConnectionFailed] OpenAI API呼び出しが失敗した場合（例: ネットワークエラー）
  # @raise [Faraday::UnauthorizedError] 認証エラーが発生した場合（無効なAPIキーなど）
  def call_chat_gpt_api(prompts)
    Async do |_task|
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
    end
  end

  # プロンプトを生成する関数
  #
  # @param path [String] テンプレートのパス
  # @param prompt_variable [Hash] テンプレートに組み込む変数の一覧
  # @param user_input [String] ユーザー入力
  # @return [Hash] 生成されたプロンプト
  #
  # @raise [FileNotFoundError] テンプレートファイルが存在しない場合
  # @raise [Psych::SyntaxError] YAMLファイルの構文が無効な場合
  def self.create_prompts(path, user_input, prompt_variable = {})
    data = File.read(path)
    # ERB を使って変数を置き換え
    renderer = ERB.new(data)
    result = renderer.result(binding)

    { 'system' => result.chomp, 'user' => user_input }
  end

  # テキスト生成結果の検証を行う関数
  #
  # @param validators [Array<Object>] 検証関数リスト
  # @param response_hash [Hash] ChatGPT APIのレスポンス
  # @return [Boolean] 検証結果
  def validates(validators, response_hash)
    validators.all? do |validator|
      if validator.call(response_hash)
        true
      else
        Rails.logger.error "Validation failed: #{response_hash}"
        break false
      end
    end
  end

  # 生成回数がチェックする関数
  #
  # @param generate_count [Integer] 生成回数
  # @param response_hash [Hash] ChatGPT APIのレスポンス
  # @param prompts [Hash] プロンプト文
  # @return [nil]
  #
  # @raise [InvalidChatGptResponseError] ChatGPTでの生成回数が上限に達した場合
  def check_generate_count(generate_count, response_hash, prompts)
    # 生成回数が上限に達した場合に終了
    return unless generate_count >= @max_create

    Rails.logger.error(
      "Invalid ChatGPT response format. Generated text: #{JSON.pretty_generate(response_hash)}, " \
      "Prompts: #{JSON.pretty_generate(prompts)}"
    )
    raise InvalidChatGptResponseError, 'Invalid response format. Generated text and prompts logged.'
  end

  # レスポンスをハッシュに変換する関数
  #
  # @param response [Hash] APIからのレスポンス
  # @return [Hash, nil] 生成されたテキストのハッシュ
  def parse_response_to_hash(response)
    # 文字列の中に改行コードが含まれている場合、改行コードを削除
    content = response['choices'][0]['message']['content'].gsub(/\r\n|\r|\n/, '')

    # 末尾に"}"がない場合、"}"を追加
    content += '}' unless content.end_with?('}')

    # JSON形式をハッシュに変換
    JSON.parse(content)
  end
end
