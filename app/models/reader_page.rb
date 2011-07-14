class ReaderPage < Page
  include WillPaginate::ViewHelpers
  attr_accessor :reader, :group
  
  description %{ Presents readers and groups with configurable access control. }
  
  def current_reader
    Reader.current
  end
  
  def readers
    if group
      group.readers.visible_to(current_reader)
    else
      Reader.visible_to(current_reader)
    end
  end
  
  def groups
    Group.visible_to(current_reader)
  end
    
  def cache?
    !!Radiant.config['readers.public?']
  end
  
  def visible?
    Radiant.config['readers.public?'] || current_reader
  end
  
  def url_for(thing)
    if thing.is_a?(Reader)
      File.join(self.url, thing.id)
    elsif thing.is_a?(Group)
      File.join(self.url, thing.slug)
    end
  end
  
  def find_by_url(url, live = true, clean = false)
    url = clean_url(url) if clean
    my_url = self.url
    return false unless url =~ /^#{Regexp.quote(my_url)}(.*)/
    raise ReaderError::AccessDenied unless visible?
    
    params = $1.split('/').compact
    self.group = Group.find_by_slug(params.first) if params.first =~ /\w/
    self.reader = Reader.find_by_id(params.last) if params.last !~ /\D/

    raise ReaderError::AccessDenied if group && !group.visible_to?(current_reader)
    raise ReaderError::AccessDenied if reader && !reader.visible_to?(current_reader)
    raise ActiveRecord::RecordNotFound if reader && group && !reader.is_in?(group)

    self
  end
  
end
