class CreateContracts < ActiveRecord::Migration[8.1]
  def change
    create_table :contracts do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.string :original_filename, null: false
      t.text :extracted_text
      t.references :contract_type, null: true, foreign_key: true
      t.integer :file_size_bytes
      t.string :status, null: false, default: "UPLOADED"

      t.timestamps
    end
    add_index :contracts, :status
  end
end
