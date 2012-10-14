class ValuesController < ApplicationController

  def create
    data = params[:value]
    poem = Poem.find_by_id(data[:poem])
    data[:poem] = poem

    @value = Value.new(data)
    @value.save

    # Save the DOM model id for later highlighting
    @did = dom_id(@value)

    respond_to do |format|
      format.js
    end
  end

  def destroy
    @value = Value.find_by_id(params[:id])
    # Save the DOM model id for later hiding
    @did = dom_id(@value)
    @value.destroy

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
