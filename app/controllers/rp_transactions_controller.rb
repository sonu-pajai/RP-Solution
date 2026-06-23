class RpTransactionsController < ApplicationController
  def index
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
    @selected_entity_id = params[:reporting_entity_id].present? ? params[:reporting_entity_id].to_i : nil
    @selected_unit_id = params[:reporting_unit_id].present? ? params[:reporting_unit_id].to_i : nil
    @selected_period_id = params[:period_id].present? ? params[:period_id].to_i : nil

    @reporting_units = @selected_entity_id ? ReportingUnit.where(reporting_entity_id: @selected_entity_id) : []

    @rp_transactions = RpTransaction.includes(:reporting_entity, :reporting_unit, :period)
    @rp_transactions = @rp_transactions.where(reporting_entity_id: @selected_entity_id) if @selected_entity_id
    @rp_transactions = @rp_transactions.where(reporting_unit_id: @selected_unit_id) if @selected_unit_id
    @rp_transactions = @rp_transactions.where(period_id: @selected_period_id) if @selected_period_id
    @rp_transactions = @rp_transactions.order(created_at: :desc)
  end

  def new
    @rp_transaction = RpTransaction.new
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
    @counterparties = RpMaster.where(category: "Director/KMP", active: true).pluck(:name)
    @transaction_types = Transaction.distinct.pluck(:transaction_type).compact
    @natures = Transaction.distinct.pluck(:nature).compact
    @sub_natures = Transaction.distinct.pluck(:sub_type).compact
  end

  def create
    @rp_transaction = RpTransaction.new(rp_transaction_params)
    if @rp_transaction.save
      redirect_to rp_transactions_path, notice: "Transaction created."
    else
      @reporting_entities = ReportingEntity.all
      @periods = Period.all
      @counterparties = RpMaster.where(category: "Director/KMP", active: true).pluck(:name)
      @transaction_types = Transaction.distinct.pluck(:transaction_type).compact
      @natures = Transaction.distinct.pluck(:nature).compact
      @sub_natures = Transaction.distinct.pluck(:sub_type).compact
      render :new, status: :unprocessable_entity
    end
  end

  def bulk_upload
    if request.post?
      file = params[:file]
      if file.blank?
        redirect_to bulk_upload_rp_transactions_path, alert: "Please select a file."
        return
      end

      require "roo"
      spreadsheet = Roo::Spreadsheet.open(file.path, extension: File.extname(file.original_filename))
      header = spreadsheet.row(1).map(&:strip)
      errors = []
      count = 0

      (2..spreadsheet.last_row).each do |i|
        row = Hash[[header, spreadsheet.row(i)].transpose]
        entity = ReportingEntity.find_by(name: row["Reporting Entity"]&.strip)
        unless entity
          errors << "Row #{i}: Reporting Entity '#{row['Reporting Entity']}' not found"
          next
        end

        unit = ReportingUnit.find_by(name: row["Reporting Unit"]&.strip, reporting_entity: entity)
        unless unit
          errors << "Row #{i}: Reporting Unit '#{row['Reporting Unit']}' not found"
          next
        end

        period = Period.find_by(month: row["Period"]&.strip)
        unless period
          errors << "Row #{i}: Period '#{row['Period']}' not found"
          next
        end

        txn = RpTransaction.new(
          reporting_entity: entity,
          reporting_unit: unit,
          period: period,
          counterparty: row["Counterparty"],
          transaction_type: row["Type of Transaction"],
          nature: row["Nature of Transaction"],
          sub_nature: row["Sub-Nature of Transaction"],
          amount: row["Amount"]
        )

        if txn.save
          count += 1
        else
          errors << "Row #{i}: #{txn.errors.full_messages.join(', ')}"
        end
      end

      if errors.empty?
        redirect_to rp_transactions_path, notice: "#{count} records uploaded successfully."
      else
        redirect_to bulk_upload_rp_transactions_path, alert: "#{count} valid records created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def reporting_units
    units = ReportingUnit.where(reporting_entity_id: params[:reporting_entity_id])
    render json: units.select(:id, :name)
  end

  def sub_natures
    items = Transaction.where(nature: params[:nature]).distinct.pluck(:sub_type).compact
    render json: items
  end

  def transaction_types
    items = Transaction.where(nature: params[:nature], sub_type: params[:sub_type]).distinct.pluck(:transaction_type).compact
    render json: items
  end

  private

  def rp_transaction_params
    params.require(:rp_transaction).permit(:reporting_entity_id, :reporting_unit_id, :period_id,
                                           :counterparty, :transaction_type, :nature, :sub_nature, :amount)
  end
end
