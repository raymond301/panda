class Group < ActiveRecord::Base
  has_and_belongs_to_many :users,  :uniq => true
  has_and_belongs_to_many :annotation_collections,  :uniq => true
  validates :name, presence: true, length: { minimum: 3 }

  def all_usernames
      self.users.map{|u| u.username}.push( User.find(self.originator).username.to_s )
  end

  def self.my_groups(user)
    Group.find_by_sql("SELECT * FROM groups AS g RIGHT JOIN groups_users AS u ON g.id = u.group_id WHERE u.user_id = #{user.id} OR g.originator = #{user.id} GROUP BY g.id;")
  end

end
