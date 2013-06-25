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
    redirect_to @poem
  end

  def destroy
    @poem = Poem.find_by_id(params[:id])

    @poem.destroy if @poem

    redirect_to poems_path

  end

  def edit
    @poem = Poem.find_by_id(params[:id])
    @html = render_to_string(:action => "edit", :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
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

    # do some miller column stuff
    $mc = nil
    $mc_selected = []
    Poem.navigate()

  end

  def new
    @poem = Poem.new()
    @poem.parent = Poem.find_by_id(params[:new_parent]) if params[:new_parent]
    @html = render_to_string(:action => "new", :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def show
    @poem = Poem.find_by_id(params[:id])
    # create a potentially new relation type
    @relation = Relation.new()
    @relation.from = @poem
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

  def to_poems
    poems = Poems.all.map{|p| [p.to_s, p.id]}
    respond_to do |format|
      format.json poems.as_json
    end
  end

end