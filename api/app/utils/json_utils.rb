# frozen_string_literal: true

# JSON文字列をハッシュに変換するためのユーティリティメソッドを提供する。
module JsonUtils
  def self.json_to_hash(json_text)
    JSON.parse(json_text)
  rescue JSON::ParserError => e
    Rails.logger.error "JSONのパースに失敗しました: #{e.message}"
    nil
  end
end
