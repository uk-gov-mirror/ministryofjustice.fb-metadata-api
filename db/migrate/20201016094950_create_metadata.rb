class CreateMetadata < ActiveRecord::Migration[6.0]
  def change
    enable_extension 'pgcrypto'
    create_table :metadata, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.jsonb :data, null: false
      t.string :created_by, null: false
      t.string :locale
      t.references :service, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end

    add_index :metadata, :locale
    add_index :metadata, :created_by
  end
end
