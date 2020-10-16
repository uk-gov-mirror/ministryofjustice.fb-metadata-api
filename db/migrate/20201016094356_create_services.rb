class CreateServices < ActiveRecord::Migration[6.0]

  def change
    enable_extension 'pgcrypto'
    create_table :services, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false
      t.string :created_by, null: false

      t.timestamps
    end

    add_index :services, :created_by
  end
end
