class PoemsController < ApplicationController

  def create
    @poem = Poem.new(params[:poem])
    @poem.save
    @poem.reload

    # copy value structure from parent type
    if @poem.parent

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
    #@poems = Poem.search(params[:search])
    if params[:search]
      @poems = Poem.search_poems(params[:search])
      @poem_types = Poem.search_poem_types(params[:search])
      @values = Poem.search_values(params[:search])
    else
      @poems = Poem.poems()
      @poem_types = Poem.poem_types()
    end
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

    if @poem.save
      @poem.reload
      redirect_to @poem
    end

  end

  def mc_navigate
    poem = Poem.find_by_id(params[:id])
    Poem.navigate(poem, params[:mc])

    respond_to do |format|
      format.js
    end
  end

end