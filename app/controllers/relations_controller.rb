class RelationsController < ApplicationController

  def create
    data = params[:relation]
    new_relation_data = Hash.new()
    new_poem_data = Hash.new()

    # get some data out of params
    new_relation_data[:from_to_phrase] = data[:from_to_phrase]
    new_relation_data[:to_from_phrase] = data[:to_from_phrase]

    # distinguish selected target poem or new poem; indicator is :to == 0
    if data[:to] == "0"
      new_relation_data[:from]          = Poem.find_by_id(data[:from])

      relation_type = RelationType.find_by_id(data[:relation_type])
      new_relation_data[:relation_type] = relation_type

      new_poem_data[:parent]       = relation_type.to
      new_poem_data[:is_poem_type] = "0"
      @poem = Poem.new(new_poem_data)
      @poem.save
      @poem.reload

      new_relation_data[:to] = @poem

      @relation = Relation.new(new_relation_data)
      @relation.save

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
    else

      new_relation_data[:from]          = Poem.find_by_id(data[:from])
      new_relation_data[:to]            = Poem.find_by_id(data[:to])

      @relation = Relation.new(new_relation_data)
      @relation.save

      @poem = new_relation_data[:from]
      respond_to do |format|
        format.js
      end


    end

  end

  def destroy
    rel = Relation.find_by_id(params[:id])
    # Save the DOM model id for later hiding
    @did = dom_id(rel)
    rel.destroy

    respond_to do |format|
      format.js
    end
  end

  def edit
    @relation = Relation.find_by_id(params[:id])
    @html = render_to_string(:action => "edit", :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def index
    @relations = Relation.all()
  end

  def new
    @relation = Relation.new()
    @from = Poem.find_by_id(params[:poem])
    @html = render_to_string(:action => "new", :formats => [:html], :layout => false)
    respond_to do |format|
      format.js
    end
  end

  def update
    rel = Relation.find_by_id(params[:id])
    rel.update_attributes!(params[:relation])

    @poem = Poem.find_by_id(rel.from_id)

    if @poem
      redirect_to @poem
    end

  end

  def relation_type_selected
    relation_type = RelationType.find_by_id(params[:relation_type])
    if relation_type
      @poems_to = relation_type.to.children

      respond_to do |format|
        format.js
      end
    end
  end

end
