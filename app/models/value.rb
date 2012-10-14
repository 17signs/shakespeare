class Value
  include MongoMapper::Document

  key :name
  key :value

  belongs_to :poem
end