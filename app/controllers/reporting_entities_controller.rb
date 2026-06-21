class ReportingEntitiesController < ApplicationController
  load_and_authorize_resource

  def index
    @reporting_entities = ReportingEntity.includes(:reporting_units).all
  end

  def new
    @reporting_entity = ReportingEntity.new
  end

  def create
    @reporting_entity = ReportingEntity.new(reporting_entity_params)
    if @reporting_entity.save
      redirect_to reporting_entities_path, notice: "Reporting Entity created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @reporting_entity = ReportingEntity.find(params[:id])
  end

  def update
    @reporting_entity = ReportingEntity.find(params[:id])
    if @reporting_entity.update(reporting_entity_params)
      redirect_to reporting_entities_path, notice: "Reporting Entity updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @reporting_entity = ReportingEntity.find(params[:id])
    @reporting_entity.destroy
    redirect_to reporting_entities_path, notice: "Reporting Entity deleted."
  end

  private

  def reporting_entity_params
    params.require(:reporting_entity).permit(:name, reporting_units_attributes: [:id, :name, :_destroy])
  end
end
