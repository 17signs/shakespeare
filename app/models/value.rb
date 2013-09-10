class Value
  include MongoMapper::Document

  key :name
  key :value
  key :overwrite
  key :removable
  key :detachable
  key :value_type
  key :reference_id, ObjectId

  belongs_to :poem

  belongs_to :reference, :class_name => 'Value'
  many :referring, :foreign_key => :reference_id, :class_name => 'Value', :dependent => :destroy

  def is_editable?
    if reference
      reference.is_editable?
    else
      overwrite == "1"
    end
  end

  def is_removable?
    if reference
      reference.is_removable?
    else
      removable == "1"
    end
  end

  def to_s
    if reference
      reference.to_s
    else
      name
    end
  end

  def value_to_s
    if reference
      reference.value
    else
      value
    end
  end

  def self.value_types
    ret = []
    ret << [I18n.t('value.input'), :input]
    ret << [I18n.t('value.area'), :text_area]
    ret
  end

end