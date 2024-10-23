# frozen_string_literal: true

# ChatGPT APIに関連するエラーを管理する基本クラス
class ChatGptApiError < AppError
  def initialize(message = 'ChatGPT API Error', http_status = 500, error_code = 1000)
    super(message, http_status, error_code)
  end
end

# YAMLファイルが見つからなかった場合のエラー
class FileNotFoundError < AppError
  def initialize(file_path)
    super("YAML file not found at path #{file_path}", 404, 1001)
  end
end

# ChatGPT APIの呼び出しが失敗した場合のエラー
class ChatGptApiCallError < AppError
  def initialize(details)
    super("Failed to call ChatGPT API. Details: #{details}", 502, 1003)
  end
end

# YAMLファイルのフォーマットが無効である場合のエラー
class InvalidYamlError < AppError
  def initialize(details)
    super("YAML file contains invalid format. Details: #{details}", 400, 1002)
  end
end
