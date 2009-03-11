module FakeSiteScope

  unless methods.include?('is_site_scoped') 
    define_method("is_site_scoped") { |*args| logger.warn "Multi_site not installed or not correct version: #{self} is not site-scoped." }
  end
  
end
