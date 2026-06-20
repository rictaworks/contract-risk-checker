jwt_secret = ENV["JWT_SECRET"]

unless Rails.env.test?
  raise "JWT_SECRET must be set and at least 32 characters" \
    if jwt_secret.blank? || jwt_secret.length < 32
end

Rails.application.config.jwt_secret = jwt_secret.presence || SecureRandom.hex(32)
