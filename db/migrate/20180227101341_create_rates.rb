class CreateRates < ActiveRecord::Migration[5.1]
  def change
    create_table :rates do |t|
      t.datetime :time
      t.float :usdBuy
      t.float :usdSell
      t.float :eurBuy
      t.float :eurSell

      t.timestamps
    end
  end
end
