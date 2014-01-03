class ValuesController < ApplicationController

  def create
    value_data = params[:value]

    @value = Value.new

    @value.poem           = Poem.find_by_id(value_data[:poem])
    @value.name           = value_data[:name]
    @value.value          = value_data[:value]
    @value.removable      = value_data[:removable]
    @value.value_type     = value_data[:value_type]
    @value.reference_poem = Poem.find_by_id(value_data[:reference_poem])
    @value.save
    @value.reload

    # Propagate new value to poems children
    @value.poem.children.each do |child|
      value = Value.new
      value.poem = child
      value.name = @value.name
      value.value = @value.value
      value.reference = @value
      value.save
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    value = Value.find_by_id(params[:id])
    # Save the DOM model id for later hiding
    @did = dom_id(value)
    #value.poem.remove_value(value.name)
    value.destroy if value

    respond_to do |format|
      format.js
    end
  end

  def edit
    @value = Value.find_by_id(params[:id])
    @options = Poem.poem_types
    @html = render_to_string(:action => 'edit', :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def new
    @value = Value.new
    @value.poem = Poem.find_by_id(params[:poem])
    @html = render_to_string(:action => 'new', :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def update
    @value = Value.find_by_id(params[:id])
    value_data = params[:value]

    value_data[:name]           ? @value.name           = value_data[:name]                            : ''
    value_data[:value]          ? @value.value          = value_data[:value]                           : ''
    value_data[:removable]      ? @value.removable      = value_data[:removable]                       : ''
    value_data[:reference_poem] ? @value.reference_poem = Poem.find_by_id(value_data[:reference_poem]) : nil

    @value.save
    @value.reload

    # Save the DOM model id for later highlighting
    @did = dom_id(@value)

    respond_to do |format|
      format.js
    end

  end

end