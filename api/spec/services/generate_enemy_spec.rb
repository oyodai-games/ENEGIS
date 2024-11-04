# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateEnemy, type: :unit do
  let(:settings_list) do
    {
      'model' => 'gpt-3.5-turbo',
      'temperature' => 0.7,
      'top_p' => 0.9,
      'n' => 1,
      'stream' => false,
      'max_tokens' => 100,
      'presence_penalty' => 0.5,
      'frequency_penalty' => 0.5,
      'max_create' => 5,
      'max_failed_access' => 3.0,
      'story_prompt_path' => '',
      'parameters_prompt_path' => '',
      'cards_prompt_path' => ''
    }
  end
  let(:yaml_data) do
    file_content = File.read('./spec/fixtures/mock_generator_response.json')
    JSON.parse(file_content)
  end


  let(:story_response) do
    {
      'name' => yaml_data['name'],
      'description' => yaml_data['description'],
      'story' => yaml_data['story']
    }
  end

  let(:parameters_response) do
    {
      'strength' => yaml_data['strength'],
      'constitution' => yaml_data['constitution'],
      'power' => yaml_data['power'],
      'dexterity' => yaml_data['dexterity'],
      'appearance' => yaml_data['appearance'],
      'intelligence' => yaml_data['intelligence'],
      'size' => yaml_data['size']
    }
  end

  let(:cards_response) do
    {
      'cards' => yaml_data['cards']
    }
  end

  let(:generated_enemy_dto) do
    merged_hash = story_response.merge(parameters_response).merge(cards_response).transform_keys(&:to_sym)
    GeneratedEnemyDto.new(**merged_hash)
  end

  let(:story_validators) { [] }
  let(:parameter_validators) { [] }
  let(:card_validators) { [] }

  let(:generate_enemy) { GenerateEnemy.new(settings_list) }

  describe '#initialize' do
    it '正しく初期化される' do
      expect(generate_enemy.instance_variable_get(:@generator)).to be_a(ChatGptApi)
      expect(generate_enemy.instance_variable_get(:@story_prompt_path)).to eq('')
      expect(generate_enemy.instance_variable_get(:@parameters_prompt_path)).to eq('')
      expect(generate_enemy.instance_variable_get(:@cards_prompt_path)).to eq('')
      expect(generate_enemy.instance_variable_get(:@story_validators)).not_to be_nil
      expect(generate_enemy.instance_variable_get(:@parameter_validators)).not_to be_nil
      expect(generate_enemy.instance_variable_get(:@card_validators)).not_to be_nil
    end
  end

  describe '#generate' do
    it '生成された敵を検証し、エラーがない場合に返す' do
      allow(generate_enemy).to receive(:generate_story).and_return(
        Async { story_response }
      )
      allow(generate_enemy).to receive(:generate_parameters).and_return(
        Async { parameters_response }
      )
      allow(generate_enemy).to receive(:generate_cards).and_return(
        Async { cards_response }
      )

      enemy = generate_enemy.generate('user_input')

      expect(enemy).not_to be_nil
      expect(enemy).to have_attributes(
        name: generated_enemy_dto.name,
        description: generated_enemy_dto.description,
        story: generated_enemy_dto.story,
        strength: generated_enemy_dto.strength,
        constitution: generated_enemy_dto.constitution,
        power: generated_enemy_dto.power,
        dexterity: generated_enemy_dto.dexterity,
        appearance: generated_enemy_dto.appearance,
        intelligence: generated_enemy_dto.intelligence,
        size: generated_enemy_dto.size,
        cards: generated_enemy_dto.cards
      )
    end
  end
end