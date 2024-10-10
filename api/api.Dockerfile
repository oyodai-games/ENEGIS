# ベースイメージとしてRubyを使用
FROM ruby:3.2

# 作業ディレクトリを設定
WORKDIR /api

# GemfileとGemfile.lockをコピー
COPY Gemfile Gemfile.lock ./

# bundlerをインストールし、Gemをインストール
RUN gem install bundler && bundle install

# プロジェクトのファイルを全てコピー
COPY . .

# Railsサーバーを実行
CMD ["rails", "server", "-b", "0.0.0.0"]
