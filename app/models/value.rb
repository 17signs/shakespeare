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
    reference ? reference.overwrite == '1' : true
  end

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
    if is_editable?
      __real_value_to_s
    else
      if reference
        reference.__real_value_to_s
      else
        __real_value_to_s
      end
    end
  end

  def get_value_type
    reference ? reference.get_value_type : :value_type
  end

  def __real_value_to_s
    if :value_type == 'check_box'
      if value == '1'
        'yes'
      else
        'no'
      end
    else
      value
    end
  end

  def self.search(search)
    if search
      Value.where({:value => Regexp.new(Regexp.escape(search), Regexp::IGNORECASE)})
    end
  end

  def self.value_types
    ret = []
    ret << [I18n.t('value.input'), :text_field]
    ret << [I18n.t('value.area'), :text_area]
    ret << [I18n.t('value.checkbox'), :check_box]
    ret << [I18n.t('value.selection'), :select]
    ret
  end

end