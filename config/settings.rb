Radiant::Configuration.add do |config|
  config.namespace :reader do |reader|
    reader.setting :allow_registration?, :label => 'Allow visitors to register'
    reader.setting :require_confirmation?, :label => 'Require confirmation of email address'
    reader.setting :layout, :integer, :options => lambda { Layout.all.collect {|l| [ l.id, l.name ] } }, :label => "Layout", :notes => "Radiant layout used to render reader-administration pages"
    reader.setting :mail_from_name, :validate => :present, :label => "Email name", :notes => "Name of person from whom administrative email seems to come"
    reader.setting :mail_from_address, :validate => :present, :label => "Email address", :notes => "Åddress of person from whom administrative email seems to come"
  end
end