class CreateReports < ActiveRecord::Migration[8.1]
  def change
    create_table :reports do |t|
      t.references :contract, null: false, foreign_key: true, index: { unique: true }
      t.integer :total_score
      t.integer :high_count, default: 0
      t.integer :medium_count, default: 0
      t.integer :low_count, default: 0
      t.text :overall_comment
      t.string :pdf_path

      t.timestamps
    end
  end
end
