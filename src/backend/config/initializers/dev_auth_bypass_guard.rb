if ENV["DEV_AUTH_BYPASS"] == "true" && !Rails.env.development?
  raise "DEV_AUTH_BYPASS=true は development 環境以外では使用できません。本番環境から削除してください。"
end
