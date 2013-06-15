class ValuesController < ApplicationController

  def create
    value_data = params[:value]
    poem = Poem.find_by_id(value_data[:poem])

    if poem
      @value = poem.add_value(value_data[:name], value_data[:value])
      redirect_to poem
    end
  end

  def destroy
    value = Value.find_by_id(params[:id])
    # Save the DOM model id for later hiding
    @did = dom_id(value)
    value.poem.remove_value(value.name)

    respond_to do |format|
      format.js
    end
  end

  def edit
    @value = Value.find_by_id(params[:id])
    respond_to do |format|
      format.js
    end
  end

  def new
    @value = Value.new()
    @value.poem = Poem.find_by_id(params[:poem])
    @html = render_to_string(:action => "new", :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def update
    @value = Value.find_by_id(params[:id])
    @value.update_attributes!(params[:value])
    @value.reload

    # Save the DOM model id for later highlighting
    @did = dom_id(@value)

    respond_to do |format|
      format.js
    end

  end

end
