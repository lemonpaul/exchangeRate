class CreateTriggers < ActiveRecord::Migration[5.1]
  def change
    create_table :triggers do |t|
      t.string :email
      t.string :currency
      t.string :operation
      t.string :kind
      t.float :rate

      t.timestamps
    end
  end
end
