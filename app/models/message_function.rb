class MessageFunction
  attr_accessor :name
  
  def initialize(name, description='')
    @name = name
  end
  
  def symbol
    @name.to_s.downcase.intern
  end
  
  def to_s
    @name
  end
  
  def description
    I18n.t("message_functions.#{@name}")
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
    MessageFunction.new('group_welcome', 'Group welcome'),
    MessageFunction.new('group_invitation', 'Group invitation' ),
    MessageFunction.new('password_reset', 'Password instructions'),
    MessageFunction.new('activation', 'Activation instructions')
  ]

end
