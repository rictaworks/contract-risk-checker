class Rack::Attack
  # IP 単位のフラッド対策（上限を緩めに設定）
  # ユーザー単位の制限はコントローラーで検証済み Google sub を使用する
  throttle("api/v1/auth/google flood by ip", limit: 100, period: 60) do |req|
    req.ip if req.path.chomp("/") == "/api/v1/auth/google" && req.post?
  end

  self.throttled_responder = lambda do |_env|
    [
      429,
      { "Content-Type" => "application/json" },
      [ { error: "Too Many Requests" }.to_json ]
    ]
  end
end
