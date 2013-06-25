class Value
  include MongoMapper::Document

  key :name
  key :value
  key :reference_id, ObjectId

  belongs_to :poem

  belongs_to :reference, :class_name => 'Value'
  many :referring, :foreign_key => :reference_id, :class_name => 'Value', :dependent => :destroy

  def to_s
    name
  end

end