class MessageHasManyGroups < ActiveRecord::Migration
  def self.up
    Message.all.each do |m|
      if g = Group.find_by_id(m.group_id)
        m.permit(g)
      end
    end
    remove_column :messages, :group_id 
  end

  def self.down
    add_column :messages, :group_id , :integer
  end
end
