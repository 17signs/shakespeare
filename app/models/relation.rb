class Relation
  include MongoMapper::Document

  key :relation_type
  key :from
  key :to

  belongs_to :relation_type

  belongs_to :from, :class_name => "Poem"
  belongs_to :to, :class_name => "Poem"

end