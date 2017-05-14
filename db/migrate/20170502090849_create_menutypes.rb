class CreateMenutypes < ActiveRecord::Migration[5.0]
  def change
    create_table :menutypes do |t|
      t.string :menutypename

      t.timestamps
    end
  end
end
