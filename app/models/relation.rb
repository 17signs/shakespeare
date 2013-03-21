class Relation
  include MongoMapper::Document

  key :relation_type
  key :from
  key :to

  belongs_to :relation_type

  belongs_to :from, :class_name => "Poem"
  belongs_to :to, :class_name => "Poem"

  validate :validate_references

  def destroy
    super
    Poem.reset_navigation
  end

  def validate_references
    status = []

    if :relation_type
      status.push('true')
    else
      status.push('false')
    end

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