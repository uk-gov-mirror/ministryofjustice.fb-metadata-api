class ChangeServiceNameToServices < ActiveRecord::Migration[6.1]
  def change
    add_index :services, :name, unique: true
  end
end
