class RelationsController < ApplicationController

  def create
    data = params[:relation]
    poem = Poem.find_by_id(data[:from])
    data[:from] = poem
    poem = Poem.find_by_id(data[:to])
    data[:to] = poem
    type = RelationType.find_by_id(data[:relation_type])
    data[:relation_type] = type

    @relation = Relation.new(data)
    @relation.save

    respond_to do |format|
      format.js
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

  def index
    @relations = Relation.all()
  end

  def new
    puts "New relation with params #{params}"
    @relation = Relation.new()
    @from = Poem.where('id' => params[:poem_id]).first
  end

end
