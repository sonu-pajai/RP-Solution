class RpListConsolidationController < ApplicationController
  def index
    @reporting_entity_id = params[:reporting_entity_id]
    @period_id = params[:period_id]
    if @reporting_entity_id.present? && @period_id.present?
      @rp_masters = RpMaster.all
      @rp_masters = @rp_masters.where(reporting_entity_id: @reporting_entity_id)
      @rp_masters = @rp_masters.where("unique_code ILIKE ? OR name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
      @rp_masters = @rp_masters.order(:created_at)
    end
  end

  def consolidate
    ids = params[:rp_master_ids]
    if ids.blank?
      redirect_to rp_list_consolidation_path(reporting_entity_id: params[:reporting_entity_id], period_id: params[:period_id]), alert: "Please select at least one record."
      return
    end

    count = 0
    ids.each do |id|
      record = RpConsolidation.find_or_initialize_by(
        rp_master_id: id,
        reporting_entity_id: params[:reporting_entity_id],
        period_id: params[:period_id]
      )
      record.assign_attributes(
        related_party_from: params[:related_party_from][id],
        related_party_upto: params[:related_party_upto][id],
        custom_input: params[:custom_input][id]
      )
      record.save!
      count += 1
    end

    redirect_to rp_list_consolidation_path(reporting_entity_id: params[:reporting_entity_id], period_id: params[:period_id]), notice: "#{count} records consolidated successfully."
  end

  def export
    require "csv"
    records = RpConsolidation.all
    records = records.where(reporting_entity_id: params[:reporting_entity_id]) if params[:reporting_entity_id].present?
    records = records.where(period_id: params[:period_id]) if params[:period_id].present?
    records = records.includes(:rp_master, :reporting_entity, :period).order(:created_at)

    if params[:search].present?
      rp_ids = RpMaster.where("unique_code ILIKE ? OR name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%").pluck(:id)
      records = records.where(rp_master_id: rp_ids)
    end

    csv_data = CSV.generate do |csv|
      csv << ["Unique Code", "Name", "Related Party From", "Related Party Upto", "Any Other Input (Custom)"]
      records.each do |rc|
        csv << [
          rc.rp_master.unique_code, rc.rp_master.name,
          rc.related_party_from, rc.related_party_upto, rc.custom_input
        ]
      end
    end
    send_data csv_data, filename: "rp_list_consolidation_#{Date.today}.csv", type: "text/csv"
  end

  def bulk_upload
    if request.post?
      file = params[:file]
      reporting_entity_id = params[:reporting_entity_id]
      period_id = params[:period_id]

      if file.blank? || reporting_entity_id.blank? || period_id.blank?
        redirect_to rp_list_consolidation_bulk_upload_path, alert: "Please select a file, reporting entity, and period."
        return
      end

      entity = ReportingEntity.find_by(id: reporting_entity_id)
      period = Period.find_by(id: period_id)

      unless entity && period
        redirect_to rp_list_consolidation_bulk_upload_path, alert: "Invalid Reporting Entity or Period."
        return
      end

      require "csv"
      count = 0
      errors = []

      CSV.foreach(file.path, headers: true).with_index(2) do |row, line|
        rp_master = RpMaster.find_by(unique_code: row["Unique Code"]&.strip)
        unless rp_master
          errors << "Row #{line}: Unique Code '#{row['Unique Code']}' not found"
          next
        end

        record = RpConsolidation.find_or_initialize_by(
          rp_master_id: rp_master.id,
          reporting_entity_id: reporting_entity_id,
          period_id: period_id
        )
        record.assign_attributes(
          related_party_from: row["Related Party From"],
          related_party_upto: row["Related Party Upto"],
          custom_input: row["Any Other Input (Custom)"]
        )

        if record.save
          count += 1
        else
          errors << "Row #{line}: #{record.errors.full_messages.join(', ')}"
        end
      end

      if errors.empty?
        redirect_to rp_list_consolidation_path(reporting_entity_id: reporting_entity_id, period_id: period_id), notice: "#{count} records uploaded successfully."
      else
        redirect_to rp_list_consolidation_bulk_upload_path, alert: "#{count} valid records created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def template
    require "csv"
    csv_data = CSV.generate do |csv|
      csv << ["Unique Code", "Name", "Related Party From", "Related Party Upto", "Any Other Input (Custom)"]
    end
    send_data csv_data, filename: "rp_list_consolidation_template.csv", type: "text/csv"
  end
end
