class MessageFunction
  attr_accessor :name, :description
  
  def initialize(name, description='')
    @name = name
    @description = description
  end
  
  def symbol
    @name.to_s.downcase.intern
  end
  
  def to_s
    @name
  end
  
  def humanize
    to_s.gsub('_', ' ')
  end
  
  def self.[](value)
    return if value.blank?
    @@functions.find { |function| function.symbol == value.to_s.downcase.intern }
  end
    
  def self.add(name, description='')
    @@functions.push(MessageFunction.new(name, description)) unless MessageFunction[name]
  end

  def self.find_all
    @@functions.dup
  end
  
  @@functions = [
    MessageFunction.new('welcome', 'Welcome'),
    MessageFunction.new('invitation', 'Invitation' ),
    MessageFunction.new('password_reset', 'Password instructions'),
    MessageFunction.new('activation', 'Activation instructions')
  ]

end
