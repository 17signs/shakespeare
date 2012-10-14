class RelationType
  include MongoMapper::Document

  key :from
  key :to

  key :from_to_phrase
  key :to_from_phrase

  belongs_to :from, :class_name => 'Poem'
  belongs_to :to, :class_name => 'Poem'

  has_many :relations

  def to_s
    from_to_phrase
  end

  def self.select_list
    RelationType.all.map{|rt| [rt.to_s, rt.id] }
  end

end