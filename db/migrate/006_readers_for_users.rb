class ReadersForUsers < ActiveRecord::Migration

  # this is mostly for updating some old sites that predate the reader machinery,
  # but it's useful housekeeping in a larger site too

  def self.up
    User.find(:all).each do |user|
      Reader.find_or_create_for_user(user)
    end
  end

  def self.down
    
  end
  
end
