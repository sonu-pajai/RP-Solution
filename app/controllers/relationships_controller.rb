class RelationshipsController < ApplicationController
  load_and_authorize_resource

  def index
    @relationships = Relationship.order(:category, :name)
  end

  def new
    @relationship = Relationship.new
  end

  def create
    @relationship = Relationship.new(relationship_params)
    if @relationship.save
      redirect_to relationships_path, notice: "Relationship created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @relationship = Relationship.find(params[:id])
  end

  def update
    @relationship = Relationship.find(params[:id])
    if @relationship.update(relationship_params)
      redirect_to relationships_path, notice: "Relationship updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @relationship = Relationship.find(params[:id])
    @relationship.destroy
    redirect_to relationships_path, notice: "Relationship deleted."
  end

  private

  def relationship_params
    params.require(:relationship).permit(:name, :category)
  end
end
