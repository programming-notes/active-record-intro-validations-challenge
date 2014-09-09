class CreateDogs < ActiveRecord::Migration
  def change
    create_table :dogs do |t|
      t.string   :name
      t.string   :license
      t.integer  :age
      t.integer  :weight
      t.integer  :owner_id

      t.timestamps
    end
  end
end
