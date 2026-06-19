class CreateRiskLevels < ActiveRecord::Migration[8.1]
  def change
    create_table :risk_levels do |t|
      t.string :name, null: false
      t.integer :score_weight, null: false

      t.timestamps
    end
    add_index :risk_levels, :name, unique: true
  end
end
