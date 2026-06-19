class CreateClauses < ActiveRecord::Migration[8.1]
  def change
    create_table :clauses do |t|
      t.references :contract, null: false, foreign_key: true
      t.string :clause_number
      t.string :clause_title
      t.text :clause_text, null: false
      t.integer :order_index, null: false

      t.timestamps
    end
    add_index :clauses, :order_index
  end
end
