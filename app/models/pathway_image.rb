class PathwayImage < ActiveRecord::Base
  has_attached_file :background, :styles => { :thumb => "80x80>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :background, :content_type => /\Aimage\/.*\Z/

  has_many :pathway_maps, :foreign_key => 'xref'

end
