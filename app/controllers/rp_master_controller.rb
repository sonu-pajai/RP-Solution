class RpMasterController < ApplicationController
  def index
    @rp_masters = RpMaster.includes(:created_by, :approved_by, :admin_approved_by)
    @rp_masters = @rp_masters.where("unique_code ILIKE ?", "%#{params[:unique_code]}%") if params[:unique_code].present?
    @rp_masters = @rp_masters.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    @rp_masters = @rp_masters.where("pan ILIKE ?", "%#{params[:pan]}%") if params[:pan].present?
    @rp_masters = @rp_masters.where(category: params[:category]) if params[:category].present?

    sort_column = %w[unique_code name pan category created_at].include?(params[:sort]) ? params[:sort] : "created_at"
    sort_direction = params[:direction] == "desc" ? "desc" : "asc"
    @rp_masters = @rp_masters.order("#{sort_column} #{sort_direction}")

    @total_count = @rp_masters.count
    @rp_masters = @rp_masters.page(params[:page])
  end

  def new
    @rp_master = RpMaster.new(active: true)
    @reporting_entity_id = params[:reporting_entity_id]
  end

  def create
    @rp_master = RpMaster.new(rp_master_params)
    @rp_master.dob_or_incorporation = parse_date(params[:rp_master][:dob_or_incorporation]) if params[:rp_master][:dob_or_incorporation].present?
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

  def show
    @rp_master = RpMaster.includes(:created_by, :approved_by, :admin_approved_by).find(params[:id])
  end

  def update
    @rp_master = RpMaster.find(params[:id])
    attrs = rp_master_params.to_h
    attrs[:dob_or_incorporation] = parse_date(attrs[:dob_or_incorporation]) if attrs[:dob_or_incorporation].present?
    if @rp_master.update(attrs)
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
        rp = RpMaster.new(
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
    headers = ["Salutation", "Name", "PAN", "Category", "Specific Relationship", "DOB/Incorporation Date", "Related to Director", "RP as per SEBI", "RP as per Companies Act", "RP as per AS-18", "RP as per IND AS-24", "Other Guidelines", "Active"]
    csv_data = CSV.generate do |csv|
      csv << headers
    end
    send_data csv_data, filename: "rp_master_template.csv", type: "text/csv"
  end

  def export
    require "csv"
    records = RpMaster.all
    records = records.where("unique_code ILIKE ?", "%#{params[:unique_code]}%") if params[:unique_code].present?
    records = records.where("name ILIKE ?", "%#{params[:name]}%") if params[:name].present?
    records = records.where("pan ILIKE ?", "%#{params[:pan]}%") if params[:pan].present?
    records = records.where(category: params[:category]) if params[:category].present?
    records = records.order(:created_at)

    csv_data = CSV.generate do |csv|
      csv << ["Salutation", "Name", "PAN", "Category", "Specific Relationship", "DOB/Incorporation Date", "Related to Director", "RP as per SEBI", "RP as per Companies Act", "RP as per AS-18", "RP as per IND AS-24", "Other Guidelines", "Active"]
      records.each do |rp|
        csv << [
          rp.salutation, rp.name, rp.pan,
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
      :other_guidelines, :active
    )
  end

  def parse_date(str)
    Date.strptime(str, "%d/%m/%Y")
  rescue
    str
  end
end
