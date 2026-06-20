require "rails_helper"

RSpec.describe "Api::V1::Auths", type: :request do
  before do
    Rails.application.routes.draw do
      namespace :api do
        namespace :v1 do
          post "auth/google", to: "auth#google"
          get "test_auth", to: "test_auth#index"
          get "test_forbidden", to: "test_auth#forbidden"
        end
      end
    end

    stub_const("Api::V1::TestAuthController", Class.new(ApplicationController) do
      def index
        render json: { message: "success", user_id: current_user.id }
      end

      def forbidden
        raise ApplicationController::ForbiddenError
      end
    end)
  end

  after do
    Rails.application.reload_routes!
  end

  let(:jwt_secret) { "test_jwt_secret_at_least_32_characters!" }
  let(:google_sub) { "google-12345" }
  let(:google_claims) do
    {
      "sub" => google_sub,
      "name" => "テストユーザー",
      "email" => "test@example.com",
      "aud" => "test-google-client-id"
    }
  end

  before do
    allow(Rails.application.config).to receive(:jwt_secret).and_return(jwt_secret)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with("GOOGLE_CLIENT_ID").and_return("test-google-client-id")
    allow(ENV).to receive(:[]).with("DEV_AUTH_BYPASS").and_return(nil)
  end

  describe "POST /api/v1/auth/google" do
    context "有効な Google ID トークンの場合" do
      before do
        allow_any_instance_of(Api::V1::AuthController)
          .to receive(:verify_google_id_token)
          .and_return(google_claims)
      end

      it "ユーザーを作成し、JWTトークンを返すこと" do
        post "/api/v1/auth/google", params: { id_token: "valid-google-id-token" }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        expect(json["token"]).to be_present
        expect(json["user"]["id"]).to be_present
        expect(json["user"].key?("display_name")).to be false

        payload = JWT.decode(json["token"], jwt_secret, true, { algorithm: "HS256" })[0]
        expect(payload["user_id"]).to eq(json["user"]["id"])
      end

      it "既存のユーザーの場合は、同じユーザーIDのJWTを返すこと" do
        user = User.create!(google_sub: google_sub)

        post "/api/v1/auth/google", params: { id_token: "valid-google-id-token" }
        expect(response).to have_http_status(:ok)

        json = JSON.parse(response.body)
        payload = JWT.decode(json["token"], jwt_secret, true, { algorithm: "HS256" })[0]
        expect(payload["user_id"]).to eq(user.id)
      end
    end

    context "無効なパラメータの場合" do
      it "id_token が無い場合は 400 Bad Request を返すこと" do
        post "/api/v1/auth/google", params: {}
        expect(response).to have_http_status(:bad_request)
        expect(JSON.parse(response.body)["error"]).to eq("id_token is required")
      end

      it "Google 検証に失敗した場合は 401 Unauthorized を返すこと" do
        allow_any_instance_of(Api::V1::AuthController)
          .to receive(:verify_google_id_token)
          .and_return(nil)

        post "/api/v1/auth/google", params: { id_token: "invalid-token" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Invalid Google ID token")
      end
    end
  end

  describe "認証フィルター (authenticate_user!)" do
    let(:user) { User.create!(google_sub: "user-123", display_name: "一般ユーザー") }
    let(:valid_token) do
      payload = { user_id: user.id, exp: 1.hour.from_now.to_i }
      JWT.encode(payload, jwt_secret, "HS256")
    end

    context "DEV_AUTH_BYPASSが有効な場合" do
      before do
        allow(ENV).to receive(:[]).with("DEV_AUTH_BYPASS").and_return("true")
        allow(Rails.env).to receive(:development?).and_return(true)
      end

      it "Authorizationヘッダーが無くても自動的に開発用ユーザーでログインされること" do
        get "/api/v1/test_auth"
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("success")

        dev_user = User.find_by(google_sub: "dev-user-001")
        expect(dev_user).to be_present
        expect(json["user_id"]).to eq(dev_user.id)
      end
    end

    context "通常認証の場合" do
      it "有効なJWTトークンがあればアクセスを許可すること" do
        get "/api/v1/test_auth", headers: { "Authorization" => "Bearer #{valid_token}" }
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)["message"]).to eq("success")
      end

      it "JWTトークンが無い場合は 401 Unauthorized を返すこと" do
        get "/api/v1/test_auth"
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end

      it "期限切れのJWTトークンの場合は 401 Unauthorized を返すこと" do
        expired_payload = { user_id: user.id, exp: 1.hour.ago.to_i }
        expired_token = JWT.encode(expired_payload, jwt_secret, "HS256")

        get "/api/v1/test_auth", headers: { "Authorization" => "Bearer #{expired_token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end

      it "署名が改ざんされたJWTトークンの場合は 401 Unauthorized を返すこと" do
        invalid_token = JWT.encode({ user_id: user.id }, "wrong_secret", "HS256")

        get "/api/v1/test_auth", headers: { "Authorization" => "Bearer #{invalid_token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end

      it "存在しないユーザーIDのJWTトークンの場合は 401 Unauthorized を返すこと" do
        payload = { user_id: 99999, exp: 1.hour.from_now.to_i }
        token = JWT.encode(payload, jwt_secret, "HS256")

        get "/api/v1/test_auth", headers: { "Authorization" => "Bearer #{token}" }
        expect(response).to have_http_status(:unauthorized)
        expect(JSON.parse(response.body)["error"]).to eq("Unauthorized")
      end
    end
  end

  describe "エラーハンドリング (Forbidden)" do
    let(:forbidden_user) { User.create!(google_sub: "user-forbidden-test") }
    let(:forbidden_token) do
      payload = { user_id: forbidden_user.id, exp: 1.hour.from_now.to_i }
      JWT.encode(payload, jwt_secret, "HS256")
    end

    it "ForbiddenErrorが発生した場合に 403 Forbidden を返すこと" do
      get "/api/v1/test_forbidden", headers: { "Authorization" => "Bearer #{forbidden_token}" }
      expect(response).to have_http_status(:forbidden)
      expect(JSON.parse(response.body)["error"]).to eq("Forbidden")
    end
  end
end
