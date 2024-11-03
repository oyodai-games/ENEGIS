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
      'frequency_penalty' => 0.5,
      'max_create' => 5,
      'max_failed_access' => 3,
      'time_to_access_refresh' => 3
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
      expect(chat_gpt_api.instance_variable_get(:@time_to_access_refresh)).to eq(3)
    end
  end

  describe '#call_chat_gpt_api' do
    it 'ChatGPT APIが正しいパラメータで呼び出され、レスポンスが返る' do
      chat_gpt_api = ChatGptApi.new(settings_list)

      # 実際のAPI呼び出し
      async_task = chat_gpt_api.call_chat_gpt_api(prompts)

      response = async_task.wait

      # レスポンスが正しく返っているか確認
      expect(response).not_to be_nil
      expect(response).not_to include('error')
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

      allow(chat_gpt_api).to receive(:call_chat_gpt_api).and_return(
        Async { api_response }
      )

      parsed_json = { 'setup' => 'Why did the chicken cross the road?', 'punchline' => 'To get to the other side!' }

      validator = ->(output) { output['setup'] == 'Why did the chicken cross the road?' }

      response = chat_gpt_api.generate_text(prompts, [validator])
      expect(response).to eq(parsed_json)
    end

    it '検証に失敗した場合、InvalidChatGptResponseErrorが発生する' do
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

      allow(chat_gpt_api).to receive(:call_chat_gpt_api).and_return(
        Async { api_response }
      )

      validator = ->(output) { output['setup'] == 'wrong setup' }

      expect do
        chat_gpt_api.generate_text(prompts, [validator])
      end.to raise_error(InvalidChatGptResponseError, /Invalid response format. Generated text and prompts logged./)
    end

    it 'ネットワーク接続に規定回数失敗した場合、設定された遅延時間が経過してからFaraday::ConnectionFailedが発生する' do
      chat_gpt_api = ChatGptApi.new(settings_list)

      allow(chat_gpt_api).to receive(:call_chat_gpt_api).and_raise(Faraday::ConnectionFailed)

      # 時間計測の開始
      Rails.logger.info(settings_list)
      expected_delay = settings_list['time_to_access_refresh'] * (settings_list['max_failed_access'] - 1)
      start_time = Time.now

      expect do
        chat_gpt_api.generate_text(prompts, [])
      end.to raise_error(Faraday::ConnectionFailed)

      # 実行時間が期待される遅延時間の差分が1未満であることを確認
      difference = Time.now - start_time - expected_delay
      expect(difference).to be < 1
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
                    '}'
      }
      response = ChatGptApi.create_prompts(prompts_path, user_input)
      expect(response).to eq(generated_prompt)
    end

    it 'ERBによる変数の埋め込みに成功する' do
      user_input = 'Hello!!'
      prompts_path = './spec/fixtures/embedding_prompt.yml'
      prompt_variable = { power: '100' }
      result = ChatGptApi.create_prompts(prompts_path, user_input, prompt_variable)
      expect(result['system']).to eq('モンスターの力は 100 です。')
    end
  end
end
