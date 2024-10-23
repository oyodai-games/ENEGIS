# frozen_string_literal: true

# アプリケーション内で使用されるカスタムエラーの基本クラス
# 各種エラーでHTTPステータスコードとエラーコードを指定できる
class AppError < StandardError
  attr_reader :http_status, :error_code

  # @param message [String] エラーメッセージ
  # @param http_status [Integer] HTTPステータスコード
  # @param error_code [Integer] アプリケーション独自のエラーコード
  def initialize(message, http_status, error_code)
    super(message)
    @http_status = http_status
    @error_code = error_code
  end
end
