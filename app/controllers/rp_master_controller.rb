class RpMasterController < ApplicationController
  def index
    @rp_masters = RpMaster.all
    @rp_masters = @rp_masters.where(reporting_entity_id: params[:reporting_entity_id]) if params[:reporting_entity_id].present?
    @rp_masters = @rp_masters.where("unique_code ILIKE ?", "%#{params[:unique_code]}%") if params[:unique_code].present?
    @rp_masters = @rp_masters.order(:created_at)
  end

  def new
    @rp_master = RpMaster.new(active: true)
    @reporting_entity_id = params[:reporting_entity_id]
  end

  def create
    @rp_master = RpMaster.new(rp_master_params)
    @rp_master.created_by = current_user
    if @rp_master.save
      redirect_to rp_master_path, notice: "RP Master record created."
    else
      @reporting_entity_id = rp_master_params[:reporting_entity_id]
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @rp_master = RpMaster.find(params[:id])
  end

  def update
    @rp_master = RpMaster.find(params[:id])
    if @rp_master.update(rp_master_params)
      redirect_to rp_master_path, notice: "RP Master record updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rp_master = RpMaster.find(params[:id])
    @rp_master.destroy
    redirect_to rp_master_path, notice: "RP Master record deleted."
  end

  def bulk_upload
    if request.post?
      file = params[:file]
      if file.blank?
        redirect_to rp_master_bulk_upload_path, alert: "Please select a file."
        return
      end

      require "csv"
      count = 0
      errors = []

      CSV.foreach(file.path, headers: true).with_index(2) do |row, line|
        entity = ReportingEntity.find_by(name: row["Reporting Entity"]&.strip)
        if entity.nil?
          errors << "Row #{line}: Reporting Entity '#{row['Reporting Entity']}' not found"
          next
        end

        rp = RpMaster.new(
          reporting_entity: entity,
          salutation: row["Salutation"],
          name: row["Name"],
          pan: row["PAN"],
          category: row["Category"],
          specific_relationship: row["Specific Relationship"],
          dob_or_incorporation: row["DOB/Incorporation Date"],
          related_to_director: row["Related to Director"]&.strip,
          related_party_sebi: row["RP as per SEBI"]&.strip&.downcase == "yes",
          related_party_companies_act: row["RP as per Companies Act"]&.strip&.downcase == "yes",
          related_party_as18: row["RP as per AS-18"]&.strip&.downcase == "yes",
          related_party_ind_as24: row["RP as per IND AS-24"]&.strip&.downcase == "yes",
          other_guidelines: row["Other Guidelines"],
          active: row["Active"]&.strip&.downcase != "no",
          created_by: current_user
        )

        if rp.save
          count += 1
        else
          errors << "Row #{line}: #{rp.errors.full_messages.join(', ')}"
        end
      end

      if errors.empty?
        redirect_to rp_master_path, notice: "#{count} records uploaded successfully."
      else
        redirect_to rp_master_bulk_upload_path, alert: "#{count} valid records created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def template
    require "csv"
    headers = ["Reporting Entity", "Salutation", "Name", "PAN", "Category", "Specific Relationship", "DOB/Incorporation Date", "Related to Director", "RP as per SEBI", "RP as per Companies Act", "RP as per AS-18", "RP as per IND AS-24", "Other Guidelines", "Active"]
    csv_data = CSV.generate do |csv|
      csv << headers
    end
    send_data csv_data, filename: "rp_master_template.csv", type: "text/csv"
  end

  def export
    require "csv"
    records = RpMaster.all
    records = records.where(reporting_entity_id: params[:reporting_entity_id]) if params[:reporting_entity_id].present?
    records = records.where("unique_code ILIKE ?", "%#{params[:unique_code]}%") if params[:unique_code].present?
    records = records.includes(:reporting_entity).order(:created_at)

    csv_data = CSV.generate do |csv|
      csv << ["Reporting Entity", "Salutation", "Name", "PAN", "Category", "Specific Relationship", "DOB/Incorporation Date", "Related to Director", "RP as per SEBI", "RP as per Companies Act", "RP as per AS-18", "RP as per IND AS-24", "Other Guidelines", "Active"]
      records.each do |rp|
        csv << [
          rp.reporting_entity&.name, rp.salutation, rp.name, rp.pan,
          rp.category, rp.specific_relationship, rp.dob_or_incorporation,
          rp.related_to_director,
          rp.related_party_sebi ? "Yes" : "No",
          rp.related_party_companies_act ? "Yes" : "No",
          rp.related_party_as18 ? "Yes" : "No",
          rp.related_party_ind_as24 ? "Yes" : "No",
          rp.other_guidelines,
          rp.active ? "Yes" : "No"
        ]
      end
    end
    send_data csv_data, filename: "rp_master_export_#{Date.today}.csv", type: "text/csv"
  end

  private

  def rp_master_params
    params.require(:rp_master).permit(
      :salutation, :name, :pan, :category, :specific_relationship,
      :related_to_director, :dob_or_incorporation, :related_party_sebi,
      :related_party_companies_act, :related_party_as18, :related_party_ind_as24,
      :other_guidelines, :active, :reporting_entity_id
    )
  end
end
