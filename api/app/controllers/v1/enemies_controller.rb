# frozen_string_literal: true

module V1
  # EnemysControllerは、V1 APIにおける敵キャラクター関連の処理を担当する。
  class EnemiesController < ApplicationController
    before_action :setting_generator, only: :create

    # 初期設定を行う関数
    def setting_generator
      file_path = Rails.root.join('config', 'generator_config.yml')
      settings_list = Psych.safe_load(File.read(file_path), aliases: true)[Rails.env]
      Rails.logger.info(settings_list)
      @generate_enemy = GenerateEnemy.new(settings_list)
    end

    # postに対応した、敵キャラクターを生成する関数
    def create
      query = query_params
      enemy = @generate_enemy.generate(query[:user_input])
      if enemy
        render json: enemy, status: :created
      else
        render json: { error: 'Failed to create enemy' }, status: :unprocessable_entity
      end
    end

    private

    # APIのリクエストパラメータを取得する関数
    #
    # @return [Hash] クエリパラメータ
    def create_params
      {
        user_input: params.require(:user_input)
      }
    end
  end
end
