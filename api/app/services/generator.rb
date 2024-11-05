# frozen_string_literal: true

require 'yaml'
require 'openai'
require 'chat_gpt_api'

# ユーザー入力を元に、夢(敵)とカード(スキル)を生成する機能を提供する。
class Generator
  # 初期化関数
  #
  # @param settings_list [Hash] モデルの設定
  def initialize(settings_list)
    @generator = ChatGptApi.new(settings_list)
    @story_prompt_path = Rails.root.join(settings_list['story_prompt_path'])
    @parameters_prompt_path = Rails.root.join(settings_list['parameters_prompt_path'])
    @cards_prompt_path = Rails.root.join(settings_list['cards_prompt_path'])
  end

  # ストーリーを生成するメソッド
  #
  # @param user_input [String] ユーザー入力
  # @param validators [Array<Object>] 出力を検証するための関数リスト
  # @param prompt_variable [Hash] プロンプトに組み込む変数の一覧
  # @return [Hash] 生成されたストーリー
  def generate_story(user_input, validators, prompt_variable = {})
    # プロンプトを元に夢のストーリーを作成
    Async do
      story_prompts = @generator.create_prompts(@story_prompt_path, user_input, prompt_variable)
      @generator.generate_text(story_prompts, validators)
    end
  end

  # パラメーターを生成するメソッド
  #
  # @param user_input [String] ユーザー入力
  # @param validators [Array<Object>] 出力を検証するための関数リスト
  # @param prompt_variable [Hash] プロンプトに組み込む変数の一覧
  # @return [Hash] 生成されたステータス
  def generate_parameters(user_input, validators, prompt_variable = {})
    # プロンプトを元に夢のステータスを作成
    Async do
      parameters_prompts = @generator.create_prompts(@parameters_prompt_path, user_input, prompt_variable)
      @generator.generate_text(parameters_prompts, validators)
    end
  end

  # カードを生成するメソッド
  #
  # @param user_input [String] ユーザー入力
  # @param validators [Array<Object>] 出力を検証するための関数リスト
  # @param prompt_variable [Hash] プロンプトに組み込む変数の一覧
  # @return [Hash] 生成されたカード
  def generate_cards(user_input, validators, prompt_variable = {})
    # プロンプトを元に夢のカードを作成
    Async do
      cards_prompts = @generator.create_prompts(@cards_prompt_path, user_input, prompt_variable)
      @generator.generate_text(cards_prompts, validators)
    end
  end
end
