if Rails.env.production?
  raise "GOOGLE_CLIENT_ID must be set in production" \
    if ENV["GOOGLE_CLIENT_ID"].blank?
end
