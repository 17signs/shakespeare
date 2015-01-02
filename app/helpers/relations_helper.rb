module RelationsHelper

  def relation_types
    I18n.t(:relation_types).map{ |key, value| [ value, key ] }
  end

end
