class PoemsController < ApplicationController

  def create
    @poem = Poem.new(params[:poem])
    @poem.save
    @poem.reload

    # copy value structure from parent type
    if @poem.parent
      @poem.parent.values.each do |pv|
        nv = Value.new
        nv.poem = @poem
        nv.name = pv.name
        nv.value = pv.value
        nv.reference = pv
        nv.save
      end
    end

    # start editing the newly created poem
    redirect_to @poem
  end

  def destroy
    @poem = Poem.find_by_id(params[:id])

    @poem.destroy if @poem

    # remove all existing lineages too, they may become invalid
    Lineage.collection.remove

    redirect_to poems_path

  end

  def edit
    @poem = Poem.find_by_id(params[:id])
    @html = render_to_string(:action => 'edit', :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def index
    # set up single return result structure
    @result = Hash.new
    @result[:cnt_poem_types] = 0
    @result[:cnt_poems] = 0
    @result[:cnt_values] = 0

    if params[:task]
      Poem.install_template_repository
    end

    if params[:search]
      @result[:poem_types] = Poem.search_poem_types(params[:search])
      @result[:poems]      = Poem.search_poems(params[:search])
      @result[:values]     = Value.search(params[:search])
    else
      @result[:poem_types] = Poem.poem_types
      @result[:poems]      = Poem.poems
    end

    # re-count
    @result[:cnt_poem_types] = @result[:poem_types].to_a.length
    @result[:cnt_poems]      = @result[:poems].to_a.length
    @result[:cnt_values]     = @result[:values].to_a.length

  end

  def new
    @poem = Poem.new
    @poem.parent = Poem.find_by_id(params[:new_parent]) if params[:new_parent]
    @mode = params[:mode]
    @html = render_to_string(:action => :new, :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def show
    @poem = Poem.find_by_id(params[:id])
    # create a potentially new relation type
    @relation = Relation.new
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

  def to_poems
    relation = Relation.find_by_id(params[:relation])
    @poems = Poem.where('parent_id' => relation.to.id) if relation
    rh = Hash.new
    rh['poems'] = @poems.to_a
    rh['ftp'] = relation.from_to_phrase
    rh['tfp'] = relation.to_from_phrase
    render :json => rh
  end

end