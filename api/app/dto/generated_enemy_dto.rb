# frozen_string_literal: true

# カードを含むEnemyのデータを保存するクラス
class GeneratedEnemyDTO
  attr_accessor :name, :description, :story, :strength, :constitution, :power, :dexterity, :appearance, :intelligence,
                :size, :cards

  def initialize(name:, description:, story:, strength:, constitution:, power:, dexterity:, appearance:, intelligence:,
                 size:, cards:)
    @name = name
    @description = description
    @story = story
    @strength = strength
    @constitution = constitution
    @power = power
    @dexterity = dexterity
    @appearance = appearance
    @intelligence = intelligence
    @size = size
    @cards = cards
  end
end
