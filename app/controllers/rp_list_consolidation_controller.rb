class RpListConsolidationController < ApplicationController
  def index
    @reporting_entity_id = params[:reporting_entity_id]
    @period_id = params[:period_id]
    @tab = params[:tab] || "to_submit"

    if @reporting_entity_id.present? && @period_id.present?
      submitted_ids = RpConsolidation.where(reporting_entity_id: @reporting_entity_id, period_id: @period_id).pluck(:rp_master_id)

      if @tab == "submitted"
        @rp_consolidations = RpConsolidation.includes(:rp_master).where(reporting_entity_id: @reporting_entity_id, period_id: @period_id)
        @rp_consolidations = @rp_consolidations.joins(:rp_master).where("rp_masters.unique_code ILIKE ? OR rp_masters.name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
        @rp_consolidations = @rp_consolidations.order(:created_at)
        @rp_consolidations = @rp_consolidations.page(params[:page])
      else
        @rp_masters = RpMaster.includes(:reporting_entity)
        @rp_masters = @rp_masters.where.not(id: submitted_ids) if submitted_ids.any?
        @rp_masters = @rp_masters.where("unique_code ILIKE ? OR name ILIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") if params[:search].present?
        @rp_masters = @rp_masters.order(:created_at)
        @rp_masters = @rp_masters.page(params[:page])
      end

      @to_submit_count = RpMaster.count - submitted_ids.size
      @submitted_count = submitted_ids.size
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

  def edit
    @rp_consolidation = RpConsolidation.includes(:rp_master).find(params[:id])
  end

  def update
    @rp_consolidation = RpConsolidation.find(params[:id])
    if @rp_consolidation.update(consolidation_params)
      redirect_to rp_list_consolidation_path(reporting_entity_id: @rp_consolidation.reporting_entity_id, period_id: @rp_consolidation.period_id, tab: "submitted"), notice: "Record updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rp_consolidation = RpConsolidation.find(params[:id])
    reporting_entity_id = @rp_consolidation.reporting_entity_id
    period_id = @rp_consolidation.period_id
    @rp_consolidation.destroy
    redirect_to rp_list_consolidation_path(reporting_entity_id: reporting_entity_id, period_id: period_id, tab: "submitted"), notice: "Record deleted."
  end

  private

  def consolidation_params
    params.require(:rp_consolidation).permit(:related_party_from, :related_party_upto, :custom_input)
  end
end
