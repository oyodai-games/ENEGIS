# frozen_string_literal: true

# ApplicationControllerは全てのコントローラのベースとなり、エラーハンドリングを提供する。
# AppErrorやStandardErrorの例外が発生した際に、適切なJSON形式のエラーレスポンスを返す。
class ApplicationController < ActionController::API
  # カスタムAppErrorの例外処理
  # AppErrorが発生した場合、HTTPステータスコードとエラーメッセージをJSONで返す
  rescue_from AppError do |e|
    render json: { error: e.message, code: e.error_code }, status: e.http_status
  end

  # 一般的なStandardErrorの例外処理
  # 予期しないエラーが発生した場合、500エラーとしてJSONでエラーメッセージを返す
  rescue_from StandardError do |e|
    render json: { error: "Internal server error: #{e.message}" }, status: :internal_server_error
  end
end
