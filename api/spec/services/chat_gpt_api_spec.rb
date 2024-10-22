# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChatGptApi, type: :unit do
  let(:settings_list) do
    {
      'model' => 'gpt-3.5-turbo',
      'temperature' => 0.7,
      'top_p' => 0.9,
      'n' => 1,
      'stream' => false,
      'max_tokens' => 100,
      'presence_penalty' => 0.5,
      'frequency_penalty' => 0.5
    }
  end

  let(:prompts) do
    {
      'system' => 'You are a helpful assistant.',
      'user' => 'Please respond in JSON format. Tell me a joke with the keys: setup, punchline.'
    }
  end

  describe '#initialize' do
    it '正しく初期化される' do
      chat_gpt_api = ChatGptApi.new(settings_list)
      expect(chat_gpt_api.instance_variable_get(:@model)).to eq('gpt-3.5-turbo')
      expect(chat_gpt_api.instance_variable_get(:@temperature)).to eq(0.7)
      expect(chat_gpt_api.instance_variable_get(:@top_p)).to eq(0.9)
      expect(chat_gpt_api.instance_variable_get(:@n)).to eq(1)
      expect(chat_gpt_api.instance_variable_get(:@stream)).to eq(false)
      expect(chat_gpt_api.instance_variable_get(:@max_tokens)).to eq(100)
      expect(chat_gpt_api.instance_variable_get(:@presence_penalty)).to eq(0.5)
      expect(chat_gpt_api.instance_variable_get(:@frequency_penalty)).to eq(0.5)
    end
  end

  describe '#call_chat_gpt_api' do
    it 'ChatGPT APIが正しいパラメータで呼び出され、レスポンスが返る' do
      chat_gpt_api = ChatGptApi.new(settings_list)

      # 実際のAPI呼び出し
      response = chat_gpt_api.call_chat_gpt_api(prompts)

      # レスポンスが正しく返っているか確認
      expect(response).not_to be_nil
      expect(response).to include('choices')
    end
  end

  describe '#generate_text' do
    it '生成されたテキストを検証し、エラーがない場合に返す' do
      chat_gpt_api = ChatGptApi.new(settings_list)

      api_response = {
        'choices' => [
          {
            'message' => {
              'content' => '{"setup": "Why did the chicken cross the road?", "punchline": "To get to the other side!"}'
            }
          }
        ]
      }

      allow(chat_gpt_api).to receive(:call_chat_gpt_api).and_return(api_response)

      parsed_json = { 'setup' => 'Why did the chicken cross the road?', 'punchline' => 'To get to the other side!' }

      validator = ->(output) { output['setup'] == 'Why did the chicken cross the road?' }

      response = chat_gpt_api.generate_text(prompts, [validator])
      expect(response).to eq(parsed_json)
    end

    it '検証に失敗した場合、nilを返す' do
      chat_gpt_api = ChatGptApi.new(settings_list)

      api_response = {
        'choices' => [
          {
            'message' => {
              'content' => '{"setup": "Why did the chicken cross the road?", "punchline": "To get to the other side!"}'
            }
          }
        ]
      }

      allow(chat_gpt_api).to receive(:call_chat_gpt_api).and_return(api_response)

      validator = ->(output) { output['setup'] == 'wrong setup' }

      response = chat_gpt_api.generate_text(prompts, [validator])
      expect(response).to be_nil
    end
  end
  describe '#create_prompts' do
    it 'プロンプトを生成できる' do
      user_input = 'Hello!!'
      prompts_path = './spec/fixtures/prompt_template.yml'
      generated_prompt = {
        'user' => 'Hello!!',
        'system' => "テストプロンプト\n\n" \
                    "出力形式：\n" \
                    "{\n" \
                    "  \"name\": \"怪物の名前\",\n" \
                    "  \"description\": \"怪物の外見や能力についての説明\",\n" \
                    "  \"story\": \"怪物が生まれるきっかけや背景を描く恐ろしい物語\"\n" \
                    "}\n"
      }
      response = ChatGptApi.create_prompts(prompts_path, user_input)
      expect(response).to eq(generated_prompt)
    end
  end
end
