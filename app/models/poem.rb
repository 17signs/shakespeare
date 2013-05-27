class Poem
  include MongoMapper::Document

  key :parent_id, ObjectId
  key :poem_name
  key :is_poem_type

  key :links_to_predecessors
  key :links_to_successors

  belongs_to :parent, :class_name => 'Poem'
  many :children, :foreign_key => :parent_id, :class_name => 'Poem', :dependent => :destroy

  has_many :values, :dependent => :destroy

  has_many :links_to_predecessors, :class_name => 'Relation', :foreign_key => 'to_id', :dependent => :destroy
  has_many :links_to_successors, :class_name => 'Relation', :foreign_key => 'from_id', :dependent => :destroy

  def destroy
    # call normal behaviour
    super

    # reset navigation
    Poem.reset_navigation
  end

  def to_s
    if poem_name && poem_name.length > 0
      poem_name
    else
      I18n.t('.poem_no_name')
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

  def has_children?
    children.length > 0
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

  def relation_types
   RelationType.where('from_id' => parent_id).map{|rt| [rt.to_s, rt.id]}
  end

# value handling

  def add_value(value_name, value_value)
    puts "adding #{value_name} = #{value_value}"
    # check existence of such value
    if has_value?(value_name)
      puts "value exists"
      get_value(value_name)
    else
      puts "new value"
      new_value = Value.new()
      new_value.name = value_name
      new_value.value = value_value
      new_value.poem = self

      new_value.save
      puts "new value saved: #{new_value}; propagate to children"

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
    puts "about to remove: #{value_name}"
    if has_value?(value_name)
      puts "#{value_name} exists"
      value = get_value(value_name)
      value.destroy
      puts "#{value_name} destroyed"
      children.each { |child| child.remove_value(value_name) }
      puts "and same for children"
    else
      puts "hmm"
      puts Value.where('poem_id' => id, :name => value_name).first
    end
  end

# class methods

  def self.poems
    Poem.where('is_poem_type' => '0')
  end

  def self.poem_types
    Poem.where('is_poem_type' => '1')
  end

  def self.poems_for_relations
    Poem.where('is_poem_type' => '0').map{|p| [p.to_s, p.id]}
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

  def self.search_poems(search)
    if search
      Poem.where({'is_poem_type' => '0', 'poem_name' => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

  def self.search_poem_types(search)
    if search
      Poem.where({'is_poem_type' => '1', 'poem_name' => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

  def self.search_values(search)
    if search
      Value.where({'value' => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

  # miller column navigation

  def self.navigate(poem=nil, index=nil)
    # the maximum miller column navigation is 4; set to 3 because index start with 0
    max_mc_length = 3

    # initial call?
    if not $mc
      # create miller column array and fill root poems, which are used for structuring
      # as first element
      $mc = []
      $mc << Poem.root_poems
      # no poem selected yet
      $mc_selected = []
    # not initial call --> handle poem and index
    else
      if poem && index
        # validate index quality
        # a) not negative
        # b) not larger than mc array length
        # convert parameter into integer
        i_index = index.to_i

        if i_index < 0 || i_index > $mc.length - 1
          throw :error
        else
          # new working index is selected index + 1; next column
          working_index = i_index + 1
          # working index bigger than maximum length --> left shift array
          if working_index > max_mc_length
            $mc.shift()
            $mc_selected.shift()
          end
          # clear array from working index to remove "old" navigation
          if working_index < $mc.length
            working_index.upto($mc.length-1) {$mc.pop()}
          end
          # clear array of selected poems
          if i_index < $mc_selected.length
            i_index.upto($mc_selected.length-1) {$mc_selected.pop()}
          end
          # now push in the new column content
          $mc << poem.links_to_successors.map{|suc| suc.to}
          $mc_selected << poem.id
        end
      end
    end
  end

  def self.reset_navigation
    $mc = nil
    Poem.navigate()
  end

end