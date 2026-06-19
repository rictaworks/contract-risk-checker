class CreateRiskAnalyses < ActiveRecord::Migration[8.1]
  def change
    create_table :risk_analyses do |t|
      t.references :clause, null: false, foreign_key: true, index: { unique: true }
      t.references :risk_level, null: true, foreign_key: true
      t.references :risk_type, null: true, foreign_key: true
      t.text :problem_description
      t.text :suggestion_text
      t.string :analysis_status, null: false, default: 'PENDING'
      t.integer :retry_count, default: 0

      t.timestamps
    end
    add_index :risk_analyses, :analysis_status
  end
end
