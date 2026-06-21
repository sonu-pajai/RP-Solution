class PeriodsController < ApplicationController
  load_and_authorize_resource

  def index
    @periods = Period.order(:financial_year, :id)
  end

  def new
    @period = Period.new
  end

  def create
    @period = Period.new(period_params)
    if @period.save
      redirect_to periods_path, notice: "Period created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @period = Period.find(params[:id])
  end

  def update
    @period = Period.find(params[:id])
    if @period.update(period_params)
      redirect_to periods_path, notice: "Period updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @period = Period.find(params[:id])
    @period.destroy
    redirect_to periods_path, notice: "Period deleted."
  end

  private

  def period_params
    params.require(:period).permit(:month, :financial_year)
  end
end
