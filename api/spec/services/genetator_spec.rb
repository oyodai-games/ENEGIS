# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Generator, type: :unit do
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
  describe '#initialize' do
    it '正しく初期化される' do
      generator = Generator.new(settings_list)
      expect(generator.instance_variable_get(:@generator)).to be_a(ChatGptApi)
      expect(generator.instance_variable_get(:@story_prompt_path).to_s).to eq('/api')
      expect(generator.instance_variable_get(:@parameters_prompt_path).to_s).to eq('/api')
      expect(generator.instance_variable_get(:@cards_prompt_path).to_s).to eq('/api')
    end
  end

  describe '#generate_story' do
  end

  describe '#generate_parameters' do
  end

  describe '#generate_cards' do
  end
end
