class CreateMenus < ActiveRecord::Migration[5.0]
  def change
    create_table :menus do |t|
      t.string :date
      t.string :name
      t.integer :price
      t.string :kcal

      t.timestamps
    end
    add_reference :menus, :menutype, foreign_key: true
  end
end
