module Admin::ReaderSettingsHelper

  def editable_setting(setting)
    setting = Radiant::Config.find_by_key(setting) unless setting.is_a? Radiant::Config
    domkey = setting.key.gsub('?', '_')
    containerid = "set_#{domkey}"
    link = link_to_remote setting.value, 
      :url => edit_admin_reader_setting_url(setting.id), 
      :method => 'get', 
      :update => containerid,
      :loading => "$('#{containerid}').addClassName('waiting');", 
      :loaded => "$('#{containerid}').removeClassName('waiting');"
    %{
  #{link}
    }
  end

  def checkbox_for_setting(setting, label)
    setting = Radiant::Config.find_by_key(setting) unless setting.is_a? Radiant::Config
    domkey = setting.key.gsub('?', '_')
    containerid = "set_#{domkey}"
    checkbox = check_box_tag setting.key.to_sym, 1, setting.value, :class => 'fancy', :id => domkey, :onchange => remote_function(
      :url => admin_reader_setting_path(setting.id),
      :with => %{'value=' + (this.checked ? 'true' : 'false')},
      :method => 'put',
      :loading => "$('#{containerid}').addClassName('waiting');",
      :success => "$('#{containerid}').removeClassName('waiting').toggleClassName('true').toggleClassName('false');"
    )
    %{
  #{checkbox}
  <label for="#{domkey}">#{label}</label>
    }
    
  end

end
