module Admin::ReaderSettingsHelper

  def editable_setting(setting)
    setting = Radiant::Config.find_by_key(setting) unless setting.is_a? Radiant::Config
    link_to_remote setting.value, :url => edit_admin_reader_setting_url(setting.id), :method => 'get', :update => setting.key, :loading => "$('#{setting.key}').addClassName('waiting');", :loaded => "$('#{setting.key}').removeClassName('waiting');"
  end

end
