class Poem
  include MongoMapper::Document

  key :parent_id, ObjectId
  key :poem_name

  belongs_to :parent, :class_name => 'Poem'
  many :children, :foreign_key => :parent_id, :class_name => 'Poem', :dependent => :destroy

  has_many :values, :dependent => :destroy

  has_many :links_to_predecessors, :class_name => 'Relation', :foreign_key => 'to_id', :dependent => :destroy
  has_many :links_to_successors, :class_name => 'Relation', :foreign_key => 'from_id', :dependent => :destroy

  has_many :is_value_of, :foreign_key => 'reference_poem_id', :class_name => 'Value', :dependent => :destroy

  def to_s
    if poem_name && poem_name.length > 0
      poem_name
    else
      I18n.t('.poem_no_name')
    end
  end

  def to_s_long
    if parent
      parent.to_s + ': ' + to_s
    else
      to_s
    end
  end

  def type
    if parent_id
      parent.to_s
    else
      ''
    end
  end

  def is_poem_type?
    parent == nil
  end

  def has_children?
    children.length > 0
  end

  def has_parent?
    parent != nil
  end

  def has_references?
    has_predecessors? || has_successors?
  end

  def has_relations?
    has_predecessors? || has_successors?
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

# value handling

  def add_value(value_name, value_value)
    # check existence of such value
    if has_value?(value_name)
      get_value(value_name)
    else
      new_value = Value.new()
      new_value.name = value_name
      new_value.value = value_value
      new_value.poem = self

      new_value.save

      children.each { |child| child.add_value(value_name, value_value) }

      new_value
    end
  end

  def get_value(value_name)
    if has_value?(value_name)
      Value.where('poem_id' => id, :name => value_name).first
    else
      nil
    end
  end

  def has_value?(value_name)
    Value.find('poem_id' => id, :name => value_name) != nil
  end

  def remove_value(value_name)
    if has_value?(value_name)
      value = get_value(value_name)
      value.destroy
      children.each { |child| child.remove_value(value_name) }
    else
      puts Value.where('poem_id' => id, :name => value_name).first
    end
  end

# class methods

  def self.meta_poems?
    Poem.where('parent_id' => nil).count != 0
  end

  def self.poems?
    Poem.where('parent_id' => {'$ne' => nil}).count != 0
  end

  def self.poems
    Poem.where('parent_id' => {'$ne' => nil})
  end

  def self.poem_types
    Poem.where('parent_id' => nil)
  end

  def self.poem_types_exist?
    Poem.poem_types.to_a.length > 0
  end

  def self.poems_for_relations
    Poem.where('parent_id' => nil).map{|p| [p.to_s, p.id]}
  end

  def relation_types
    Relation.where('from_id' => id).map{|r| [r.to_s, r.id]}
  end

  def self.poem_types_for_relations
    Poem.where('is_poem_type' => '1').map{|p| [p.to_s, p.id]}
  end

  def self.root_poems
    a = []
    Poem.where('parent_id' => {'$ne' => nil}).each do |p|
      if not p.has_predecessors?
        a << p
      end
    end
    a
  end

  def self.search_poems(search)
    if search
      Poem.where({'parent_id' => {'$ne' => nil}, 'poem_name' => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

  def self.search_poem_types(search)
    if search
      Poem.where({'parent_id' => nil, 'poem_name' => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

  # template repository
  def self.install_template_repository
    unless self.meta_poems?
      # User is used as reference poem for business terms data owner
      p_user = Poem.new({:poem_name => 'User'})
      p_user.save
      ['ID', 'Department'].each do |name|
        Value.new({:name => name, :value_type => :text_field, :poem => p_user}).save
      end

      p_business_term = Poem.new({:poem_name => 'Business Term'})
      p_business_term.save
      Value.new({:name => 'Description', :value_type => :text_area, :poem => p_business_term}).save
      Value.new({:name => 'Data Owner', :value_type => 'reference_poem', :reference_poem => p_user, :poem => p_business_term}).save
      Relation.new({:from => p_business_term, :to => p_business_term, :from_to_phrase => 'references', :to_from_phrase => 'is referenced by'}).save

      p_folder = Poem.new({:poem_name => 'Folder'})
      p_folder.save
      Relation.new({:from => p_folder, :to => p_business_term, :from_to_phrase => 'contains business term', :to_from_phrase => 'is part of folder'}).save
      Relation.new({:from => p_folder, :to => p_folder, :from_to_phrase => 'is structured by folder', :to_from_phrase => 'structures folder'}).save

      p_glossary = Poem.new({:poem_name => 'Glossary'})
      p_glossary.save
      Relation.new({:from => p_glossary, :to => p_folder, :from_to_phrase => 'is structured by folder', :to_from_phrase => 'structures glossary'}).save
    end
  end

end
