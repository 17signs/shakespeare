class PoemsController < ApplicationController

  def create
    @poem = Poem.new(params[:poem])
    @poem.save
    @poem.reload

    # copy value structure from parent type if requested
    if params[:copy_value_fields] && @poem.parent

      @poem.parent.values.each do |pv|
        nv = Value.new()
        nv.poem = @poem
        nv.name = pv.name
        nv.value = pv.value
        nv.save
      end

    end

    # start editing the newly created poem
    redirect_to edit_poem_path(@poem)
  end

  def destroy
    @poem = Poem.find_by_id(params[:id])
    @poem.destroy if @poem
    redirect_to poems_path
  end

  def edit
    @poem = Poem.find_by_id(params[:id])
    @relations_from = @poem.links_to_predecessors
    @relations_to = @poem.links_to_successors
    @relation = Relation.new()
    @value = Value.new()
  end

  def index
    @poems = Poem.all()
  end

  def new
    @poem = Poem.new()
  end

  def show
    @poem = Poem.find_by_id(params[:id])
  end

  def update
    @poem = Poem.find_by_id(params[:id])
    @poem.update_attributes!(params[:poem])
    #@poem.properties = params[:properties]
    #@poem.values = params[:values] if params[:values]
    if @poem.save
      @poem.reload
      redirect_to @poem
    end
  end

end