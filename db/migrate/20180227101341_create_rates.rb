# Create rates class
class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.integer :currency
      t.integer :operation
      t.float :rate
      t.timestamps
    end
  end
end
