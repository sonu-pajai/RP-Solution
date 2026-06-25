class ReportingEntitiesController < ApplicationController
  load_and_authorize_resource except: [:bulk_upload, :template]

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

  def bulk_upload
    if request.post?
      file = params[:file]
      if file.blank?
        redirect_to bulk_upload_reporting_entities_path, alert: "Please select a file."
        return
      end

      require "csv"
      count = 0
      errors = []

      CSV.foreach(file.path, headers: true).with_index(2) do |row, line|
        entity = ReportingEntity.new(name: row["Name"]&.strip)
        if entity.save
          units = row["Reporting Units"]&.strip
          if units.present?
            units.split(";").each { |u| entity.reporting_units.create(name: u.strip) }
          end
          count += 1
        else
          errors << "Row #{line}: #{entity.errors.full_messages.join(', ')}"
        end
      end

      if errors.empty?
        redirect_to reporting_entities_path, notice: "#{count} records uploaded."
      else
        redirect_to bulk_upload_reporting_entities_path, alert: "#{count} created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def template
    require "csv"
    csv_data = CSV.generate { |csv| csv << ["Name", "Reporting Units"] }
    send_data csv_data, filename: "reporting_entities_template.csv", type: "text/csv"
  end

  private

  def reporting_entity_params
    params.require(:reporting_entity).permit(:name, reporting_units_attributes: [:id, :name, :_destroy])
  end
end
