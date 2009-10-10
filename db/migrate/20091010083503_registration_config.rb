class RegistrationConfig < ActiveRecord::Migration
  def self.up
    if Radiant::Config['reader.allow_registration?'].nil?
      Radiant::Config['reader.allow_registration?'] = true
    end
  end

  def self.down
  end
end
