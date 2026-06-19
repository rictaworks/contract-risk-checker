# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# 契約種別マスタ
contract_types = [
  { name: "売買", description: "商品・サービスの売買に関する契約" },
  { name: "業務委託", description: "業務の委託に関する契約" },
  { name: "NDA", description: "秘密保持に関する契約" },
  { name: "雇用", description: "雇用・労働に関する契約" },
  { name: "賃貸借", description: "不動産等の賃貸借に関する契約" },
  { name: "ライセンス", description: "知的財産権のライセンスに関する契約" },
  { name: "その他", description: "上記以外の契約" }
]
contract_types.each do |ct|
  ContractType.find_or_create_by!(name: ct[:name]) do |record|
    record.description = ct[:description]
  end
end

# リスクレベルマスタ
risk_levels = [
  { name: "高", score_weight: 30 },
  { name: "中", score_weight: 10 },
  { name: "低", score_weight: 2 },
  { name: "なし", score_weight: 0 }
]
risk_levels.each do |rl|
  RiskLevel.find_or_create_by!(name: rl[:name]) do |record|
    record.score_weight = rl[:score_weight]
  end
end

# リスク種別マスタ
risk_types = [
  "損害賠償", "秘密保持", "競業避止", "自動更新", "解除条件",
  "準拠法", "仲裁", "支払", "期間", "知的財産", "不可抗力", "その他"
]
risk_types.each do |rt_name|
  RiskType.find_or_create_by!(name: rt_name)
end
