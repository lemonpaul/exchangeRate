class CreateTriggers < ActiveRecord::Migration[5.1]
  def change
    create_table :triggers do |t|
      t.string :email
      t.integer :currency
      t.integer :operation
      t.integer :kind
      t.float :rate

      t.timestamps
    end
  end
end
