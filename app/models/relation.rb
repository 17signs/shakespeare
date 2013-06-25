class Relation
  include MongoMapper::Document

  key :from
  key :to
  key :from_to_phrase
  key :to_from_phrase
  key :parent_id, ObjectId

  belongs_to :parent, :class_name => 'Relation'

  belongs_to :from, :class_name => "Poem"
  belongs_to :to, :class_name => "Poem"

  validate :validate_references

  def destroy
    super
    Poem.reset_navigation
  end

  def to_s
    from_to_phrase
  end

  def validate_references
    status = []

    if :from
      status.push('true')
    else
      status.push('false')
    end

    if :to
      status.push('true')
    else
      status.push('false')
    end

    if status.include?('false')
      errors.add '', 'references must be filled'
    end

  end

end