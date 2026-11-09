class CreateEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :events do |t|
      t.string :source, null: false
      t.string :external_id, null: false
      t.string :title, null: false
      t.text :description
      t.string :image_url
      t.datetime :starts_at, null: false
      t.datetime :ends_at
      t.string :event_url
      t.string :address
      t.string :city
      t.string :postal_code
      t.string :country
      t.string :organiser_name
      t.boolean :available
      t.integer :minimum_price_cents
      t.string :category
      t.string :subcategory
      t.string :event_type

      t.timestamps
    end

    add_index :events, [:source, :external_id], unique: true
  end
end
