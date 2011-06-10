class Admin::GroupInvitationsController < ApplicationController
  require 'csv'
  
  before_filter :find_group, :only => [:new, :create]

  def new

  end

  def create
    if params[:invite_reader] || params[:import_reader]
      notice = []
      if invites = params[:invite_reader]
        invite_counter = 0
        invites.each do |i|
          if reader = Reader.find_by_id(i)
            reader.groups << @group unless reader.is_in?(@group)
            @group.send_welcome_to(reader)
            invite_counter += 1
          end
        end
        notice << "#{invite_counter} existing"
      end
      if imports = params[:import_reader]
        import_counter = 0
        imports.each do |i|
          r = params["reader_#{i}".to_sym]
          reader = Reader.new(r)
          reader.create_password!
          if reader.save!
            reader.groups << @group
            reader.send_group_invitation_message(@group)
            import_counter += 1
          end
          notice << "#{import_counter} new"
        end
      end
      flash[:notice] = notice.join(' and ') + " readers invited into the #{@group.name} group"
      redirect_to admin_group_url(@group)
    else 
      if params[:readerlist] && @readers = readers_from_csv(params[:readerlist])
        render :action => 'preview'
      else
        render :action => 'new'
      end
    end
  end

private

  def find_group
    @group = Group.find(params[:group_id])
  end

  def readers_from_csv(readerdata)
    readers = []
    CSV::StringReader.parse(readerdata).each do |line|
      csv = line.collect {|value| value ? value.gsub(/^ */, '').chomp : ''}
      input = {}
      input[:honorific] = csv.shift if Radiant::Config['reader.use_honorifics?']
      [:name, :email, :login, :phone].each {|field| input[field] = csv.shift}
      r = Reader.find_by_email(input[:email]) || Reader.new(input)
      r.create_password!    #only for validation purposes: not saved not passed through
      r.login = generate_login(input[:name]) if r.login.blank?
      r.valid?    # so that errors can be shown on the confirmation form
      readers << r
    end
    readers
  end

  def generate_login(name)
    names = name.split
    initials = names.map {|n| n.slice(0,1)}
    initials.pop
    initials.push(names.last).join('_').downcase
  end

end
