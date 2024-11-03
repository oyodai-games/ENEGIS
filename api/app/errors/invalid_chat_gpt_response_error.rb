# frozen_string_literal: true

# アプリケーション内で使用されるカスタムエラーの基本クラス
# 各種エラーでHTTPステータスコードとエラーコードを指定できる
class InvalidChatGptResponseError < StandardError
  def initialize(message = 'ChatGPTから期待するフォーマットの出力を取得できませんでした')
    super(message)
  end
end
