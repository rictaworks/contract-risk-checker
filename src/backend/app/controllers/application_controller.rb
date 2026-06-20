class ApplicationController < ActionController::API
  class UnauthorizedError < StandardError; end
  class ForbiddenError < StandardError; end

  rescue_from UnauthorizedError, with: :render_unauthorized
  rescue_from ForbiddenError, with: :render_forbidden

  before_action :authenticate_user!

  attr_reader :current_user

  private

  def authenticate_user!
    if Rails.env.development? && ENV["DEV_AUTH_BYPASS"] == "true" && request.local?
      @current_user = User.find_or_create_by!(google_sub: "dev-user-001")
      return
    end

    token = request.headers["Authorization"]&.split(" ")&.last
    raise UnauthorizedError unless token

    begin
      payload = JWT.decode(token, Rails.application.config.jwt_secret, true, { algorithm: "HS256" })[0]
      @current_user = User.find(payload["user_id"])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      raise UnauthorizedError
    end
  end

  def render_unauthorized
    render json: { error: "Unauthorized" }, status: :unauthorized
  end

  def render_forbidden
    render json: { error: "Forbidden" }, status: :forbidden
  end
end
