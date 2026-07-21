class PeriodsController < ApplicationController
  load_and_authorize_resource except: [:bulk_upload, :template]

  def index
    @periods = Period.order(:financial_year, :id).page(params[:page])
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

  def bulk_upload
    if request.post?
      file = params[:file]
      if file.blank?
        redirect_to bulk_upload_periods_path, alert: "Please select a file."
        return
      end

      require "csv"
      count = 0
      errors = []

      CSV.foreach(file.path, headers: true).with_index(2) do |row, line|
        p = Period.new(month: row["Month"]&.strip, financial_year: row["Financial Year"]&.strip)
        p.save ? count += 1 : (errors << "Row #{line}: #{p.errors.full_messages.join(', ')}")
      end

      if errors.empty?
        redirect_to periods_path, notice: "#{count} records uploaded."
      else
        redirect_to bulk_upload_periods_path, alert: "#{count} created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def template
    require "csv"
    csv_data = CSV.generate { |csv| csv << ["Month", "Financial Year"] }
    send_data csv_data, filename: "periods_template.csv", type: "text/csv"
  end

  private

  def period_params
    params.require(:period).permit(:month, :financial_year, :month_number)
  end
end
