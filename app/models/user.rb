class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable,
         :trackable, :validatable, :authentication_keys => [:username]
  has_and_belongs_to_many :groups

  # attr_accessor :username  ## removing allows me to seed db

  def my_annotations_or_group_annotaitons
    if self.current_group_id == 0
        AnnotationCollection.where(originator_id: self.id)
    else
       AnnotationCollection.find_by_sql("SELECT * FROM annotation_collections AS a JOIN annotation_collections_groups AS g ON a.id = g.annotation_collection_id WHERE g.group_id = #{self.current_group_id} GROUP BY a.id;")
    end


  end

  def email_required?
    false
  end

  def email_changed?
    false
  end

end
