class Admin::RelationTypesController < ApplicationController

  def index
    @relation_types = RelationType.all()
  end

  def show
    @relation_type = RelationType.find_by_id(params[:id])
  end

  def edit
    @relation_type = RelationType.find_by_id(params[:id])
  end

  def new
    @relation_type = RelationType.new()
  end

  def create
    data = params[:relation_type]

    pf = Poem.find_by_id(data[:from])
    data[:from] = pf
    pt = Poem.find_by_id(data[:to])
    data[:to] = pt

    @relation_type = RelationType.new(data)
    @relation_type.save
    @relation_type.reload
    redirect_to [:admin, @relation_type]
  end

  def destroy
    relation_type = RelationType.find_by_id(params[:id])
    relation_type.destroy

    @relation_types = RelationType.all()
    redirect_to admin_relation_types_path
  end

  def update
    @relation_type = RelationType.find_by_id(params[:id])
    data = params[:relation_type]

    pf = Poem.find_by_id(data[:from_id])
    data[:from] = pf
    pt = Poem.find_by_id(data[:to_id])
    data[:to] = pt

    @relation_type.update_attributes!(data)
    @relation_type.reload
    redirect_to [:admin, @relation_type]
  end

end
