# frozen_string_literal: true

require 'rails_helper'

RSpec.describe JsonUtils do
  let(:valid_json) { '{"name": "Test", "age": 30}' }
  let(:invalid_json) { '{"name": "Test", "age": 30' } # 不完全なJSON

  context 'when valid JSON is provided' do
    it 'parses the JSON string and returns a hash' do
      result = JsonUtils.json_to_hash(valid_json)
      expect(result).to eq({ 'name' => 'Test', 'age' => 30 })
    end
  end

  context 'when invalid JSON is provided' do
    it 'logs an error and returns nil' do
      # ログの出力をテスト
      expect(Rails.logger).to receive(:error).with(/JSONのパースに失敗しました:/)

      result = JsonUtils.json_to_hash(invalid_json)
      expect(result).to be_nil
    end
  end
end
