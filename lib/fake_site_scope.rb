module FakeSiteScope

  def self.included(base)
    base.class_eval do
      unless methods.include?('is_site_scoped') 
        define_method("is_site_scoped") { |*args| STDERR.puts "Multi_site not installed or not correct version: #{self} is not site-scoped." }
      end
    end
  end  
end
