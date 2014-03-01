class Value
  include MongoMapper::Document

  key :name
  key :value
  key :removable
  key :value_type

  belongs_to :poem

  belongs_to :reference, :class_name => 'Value'
  many :referring, :foreign_key => :reference_id, :class_name => 'Value', :dependent => :destroy

  belongs_to :reference_poem, :class_name => 'Poem'

  def is_removable?
    reference ? reference.removable == '1' : true
  end

  def to_s
    if reference
      reference.to_s
    else
      name
    end
  end

  def value_to_s
    case get_value_type
      when 'reference_poem'
        reference_poem.to_s
      else
        value
    end
  end

  def get_value_type
    reference ? reference.get_value_type : value_type
  end

  def self.search(search)
    if search
      Value.where({:value => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

end