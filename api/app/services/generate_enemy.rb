# frozen_string_literal: true

require 'generator'
require 'generated_enemy_dto'
# 敵の生成を行うクラス
class GenerateEnemy < Generator
  # 初期化関数
  #
  # @param settings_list [Hash] モデルの設定
  def initialize(settings_list)
    super(settings_list)

    @story_validators = []
    @parameter_validators = []
    @card_validators = []
  end

  # Enemyを生成するメソッド
  #
  # @param user_input [String] ユーザー入力
  # @param enemy_prompts [Array<String>] プロンプトのパス
  def generate(user_input)
    # プロンプトを元に夢のストーリーを作成
    generate_story_task = generate_story(user_input, @story_validators)
    story = generate_story_task.wait

    # プロンプトを元に夢のステータスを作成
    generate_parameters_task = generate_parameters(story.to_s, @parameter_validators)
    parameters = generate_parameters_task.wait

    # プロンプトを元にスキルを作成
    generate_cards_task = generate_cards(story.to_s, @card_validators, parameters)
    cards = generate_cards_task.wait

    # ストーリー・ステータス・スキルを保存
    GeneratedEnemyDto.new(
      name: story['name'],
      description: story['description'],
      story: story['story'],
      strength: parameters['strength'],
      constitution: parameters['constitution'],
      power: parameters['power'],
      dexterity: parameters['dexterity'],
      appearance: parameters['appearance'],
      intelligence: parameters['intelligence'],
      size: parameters['size'],
      cards: cards['cards']
    )
  end
end
