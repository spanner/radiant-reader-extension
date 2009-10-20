class Contacts < ActiveRecord::Migration
  def self.up
    add_column :readers, :phone, :string
    add_column :readers, :organisation, :string
    add_column :readers, :post_building, :string
    add_column :readers, :post_street, :string
    add_column :readers, :post_place, :string
    add_column :readers, :post_town, :string
    add_column :readers, :post_county, :string
    add_column :readers, :postcode, :string
  end

  def self.down
    remove_column :readers, :phone
    remove_column :readers, :organisation
    remove_column :readers, :post_building
    remove_column :readers, :post_street
    remove_column :readers, :post_place
    remove_column :readers, :post_town
    remove_column :readers, :post_county
    remove_column :readers, :postcode
  end
end
