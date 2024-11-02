# frozen_string_literal: true

# ApplicationControllerは全てのコントローラのベースとなり、エラーハンドリングを提供する。
# AppErrorやStandardErrorの例外が発生した際に、適切なJSON形式のエラーレスポンスを返す。
class ApplicationController < ActionController::API
  # カスタムAppErrorの例外処理
  # AppErrorが発生した場合、HTTPステータスコードとエラーメッセージをJSONで返す
  # rescue_from AppError do |e|
  #   render json: { error: e.message, code: e.error_code }, status: e.http_status
  # end

  # OpenAI API呼び出しが失敗した場合（ネットワークエラーなど）
  rescue_from Faraday::ConnectionFailed do |error|
    Rails.logger.error("Connection failed: #{error.message}\n#{error.backtrace.join("\n")}")
    render json: { error: 'Connection to OpenAI API failed. Please try again later.' }, status: :service_unavailable
  end

  # 認証エラーが発生した場合（無効なAPIキーなど）
  rescue_from Faraday::UnauthorizedError do |error|
    Rails.logger.error("Unauthorized access: #{error.message}\n#{error.backtrace.join("\n")}")
    render json: { error: 'Unauthorized access. Please check your API credentials.' }, status: :internal_server_error
  end

  # OpenAI API呼び出しで予期しないエラーが発生した場合
  rescue_from ChatGptApiCallError do |error|
    Rails.logger.error("Unexpected ChatGPT API call error: #{error.message}\n#{error.backtrace.join("\n")}")
    render json: { error: 'Unexpected error occurred while calling ChatGPT API.' }, status: :internal_server_error
  end

  # テンプレートファイルが存在しない場合
  rescue_from FileNotFoundError do |error|
    Rails.logger.error("File not found: #{error.message}\n#{error.backtrace.join("\n")}")
    render json: { error: 'Template file not found.' }, status: :internal_server_error
  end

  # YAMLファイルの構文が無効な場合
  rescue_from Psych::SyntaxError do |error|
    Rails.logger.error("Invalid YAML syntax: #{error.message}\n#{error.backtrace.join("\n")}")
    render json: { error: 'Invalid YAML file syntax.' }, status: :internal_server_error
  end

  # YAMLのパース中に発生する予期しないエラー
  rescue_from StandardError do |error|
    Rails.logger.error("Unexpected error: #{error.message}\n#{error.backtrace.join("\n")}")
    render json: { error: 'An unexpected error occurred. Please try again later.' }, status: :internal_server_error
  end
end
