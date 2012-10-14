class Poem
  include MongoMapper::Document

  key :parent_id, ObjectId
  key :poem_name
  key :is_poem_type

  key :links_to_predecessors
  key :links_to_successors

  belongs_to :parent, :class_name => 'Poem'
  many :children, :foreign_key => :parent_id, :class_name => 'Poem'

  has_many :values

  has_many :links_to_predecessors, :class_name => 'Relation', :foreign_key => 'to_id'
  has_many :links_to_successors, :class_name => 'Relation', :foreign_key => 'from_id'

  has_many :from_relations, :class_name => 'RelationType', :foreign_key => 'to_id'
  has_many :to_relations, :class_name => 'RelationType', :foreign_key => 'from_id'

  def to_s
    if poem_name
      poem_name
    else
      'no name yet'
    end
  end

  def type
    if parent_id
      parent.to_s
    else
      ""
    end
  end

  def is_poem_type?
    is_poem_type == '1'
  end

  def has_predecessors?
    links_to_predecessors != []
  end

  def has_successors?
    links_to_successors != []
  end

  def has_values?
    values.length > 0
  end

  def self.poem_types
    Poem.where('is_poem_type' => '1').map{|p| [p.to_s, p.id]}
  end

  def self.poems_for_relations
    Poem.where('is_poem_type' => '0')
  end

  def self.poem_types_for_relations
    Poem.where('is_poem_type' => '1').map{|p| [p.to_s, p.id]}
  end

  def self.root_poems
    a = []
    Poem.where('is_poem_type' => '0').each do |p|
      if not p.has_predecessors?
        a << p
      end
    end
    a
  end

  def self.search(search, advanced_search)
    if search
      if advanced_search
        Value.where({'value' => Regexp.new(search)}).map{|v| v.poem}
      else
        Poem.where({'poem_name' => Regexp.new(search)}).to_a
      end
    else
      self.root_poems
    end
  end

end