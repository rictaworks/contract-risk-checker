class CreateRiskTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :risk_types do |t|
      t.string :name, null: false
      t.text :description

      t.timestamps
    end
    add_index :risk_types, :name, unique: true
  end
end
