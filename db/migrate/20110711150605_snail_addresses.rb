class SnailAddresses < ActiveRecord::Migration
  def self.up
    rename_column :readers, :post_building, :post_line1
    rename_column :readers, :post_street, :post_line2
    rename_column :readers, :post_town, :post_city
    rename_column :readers, :post_county, :post_province
    add_column :readers, :post_country, :string
    remove_column :readers, :post_place
  end

  def self.down
    add_column :readers, :post_place, :string
    rename_column :readers, :post_line1, :post_building
    rename_column :readers, :post_line2, :post_street
    rename_column :readers, :post_city, :post_place
    rename_column :readers, :post_province, :post_county
    remove_column :readers, :post_country
  end
end
