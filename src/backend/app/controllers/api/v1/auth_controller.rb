require "net/http"
require "uri"

class Api::V1::AuthController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :google ]

  GOOGLE_TOKENINFO_URL = "https://oauth2.googleapis.com/tokeninfo"
  MAX_TOKEN_LENGTH = 2048
  TOKENINFO_OPEN_TIMEOUT = 5
  TOKENINFO_READ_TIMEOUT = 5
  RATE_LIMIT_PER_SUB = 10
  RATE_LIMIT_WINDOW = 60.seconds

  def google
    id_token = params[:id_token]

    if id_token.nil?
      render json: { error: "id_token is required" }, status: :bad_request
      return
    end

    unless id_token.is_a?(String)
      render json: { error: "id_token must be a string" }, status: :bad_request
      return
    end

    if id_token.blank?
      render json: { error: "id_token is required" }, status: :bad_request
      return
    end

    claims = verify_google_id_token(id_token)
    unless claims
      render json: { error: "Invalid Google ID token" }, status: :unauthorized
      return
    end

    if sub_rate_limited?(claims["sub"])
      render json: { error: "Too Many Requests" }, status: :too_many_requests
      return
    end

    user = User.find_or_create_by!(google_sub: claims["sub"])

    payload = { user_id: user.id, exp: 30.days.from_now.to_i }
    token = JWT.encode(payload, Rails.application.config.jwt_secret, "HS256")

    render json: { token: token, user: { id: user.id } }, status: :ok
  end

  private

  def sub_rate_limited?(sub)
    key = "auth:rate:#{sub}"
    count = if Rails.cache.write(key, 1, expires_in: RATE_LIMIT_WINDOW, unless_exist: true)
      1
    else
      Rails.cache.increment(key).to_i
    end
    count > RATE_LIMIT_PER_SUB
  end

  def verify_google_id_token(id_token)
    return nil if id_token.length > MAX_TOKEN_LENGTH

    uri = URI("#{GOOGLE_TOKENINFO_URL}?id_token=#{URI.encode_www_form_component(id_token)}")
    response = Net::HTTP.start(
      uri.host, uri.port,
      use_ssl: uri.scheme == "https",
      open_timeout: TOKENINFO_OPEN_TIMEOUT,
      read_timeout: TOKENINFO_READ_TIMEOUT
    ) { |http| http.get(uri.request_uri) }
    return nil unless response.is_a?(Net::HTTPSuccess)

    claims = JSON.parse(response.body)
    return nil unless claims["aud"] == ENV["GOOGLE_CLIENT_ID"]

    claims
  rescue JSON::ParserError, SocketError, Timeout::Error, Net::OpenTimeout, Net::ReadTimeout => e
    Rails.logger.error "Google token verification failed: #{e.message}"
    nil
  end
end
