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
    @rp_transactions = @rp_transactions.page(params[:page])
  end

  def show
    @rp_transaction = RpTransaction.includes(:reporting_entity, :reporting_unit, :period).find(params[:id])
  end

  def new
    @rp_transaction = RpTransaction.new(
      reporting_entity_id: params[:reporting_entity_id],
      reporting_unit_id: params[:reporting_unit_id],
      period_id: params[:period_id]
    )
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
    @counterparties = RpMaster.where(active: true).pluck(:name)
    @natures = Transaction.active.distinct.pluck(:nature).compact
    @reporting_units = params[:reporting_entity_id].present? ? ReportingUnit.where(reporting_entity_id: params[:reporting_entity_id]) : []
  end

  def create
    @rp_transaction = RpTransaction.new(rp_transaction_params)
    if @rp_transaction.save
      redirect_to rp_transactions_path(
        reporting_entity_id: @rp_transaction.reporting_entity_id,
        reporting_unit_id: @rp_transaction.reporting_unit_id,
        period_id: @rp_transaction.period_id
      ), notice: "Transaction created."
    else
      @reporting_entities = ReportingEntity.all
      @periods = Period.all
      @counterparties = RpMaster.where(active: true).pluck(:name)
      @natures = Transaction.active.distinct.pluck(:nature).compact
      @reporting_units = @rp_transaction.reporting_entity_id.present? ? ReportingUnit.where(reporting_entity_id: @rp_transaction.reporting_entity_id) : []
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @rp_transaction = RpTransaction.find(params[:id])
    @reporting_entities = ReportingEntity.all
    @periods = Period.all
    @counterparties = RpMaster.where(active: true).pluck(:name)
    @natures = Transaction.distinct.pluck(:nature).compact
  end

  def update
    @rp_transaction = RpTransaction.find(params[:id])
    if @rp_transaction.update(rp_transaction_params)
      redirect_to rp_transactions_path, notice: "Transaction updated."
    else
      @reporting_entities = ReportingEntity.all
      @periods = Period.all
      @counterparties = RpMaster.where(active: true).pluck(:name)
      @natures = Transaction.distinct.pluck(:nature).compact
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @rp_transaction = RpTransaction.find(params[:id])
    @rp_transaction.destroy
    redirect_to rp_transactions_path, notice: "Transaction deleted."
  end

  def bulk_upload
    if request.post?
      file = params[:file]
      mode = params[:mode] || "create"

      if file.blank?
        redirect_to bulk_upload_rp_transactions_path, alert: "Please select a file."
        return
      end

      require "roo"
      spreadsheet = Roo::Spreadsheet.open(file.path, extension: File.extname(file.original_filename))
      header = spreadsheet.row(1).map(&:strip)
      errors = []
      created = 0
      updated = 0

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

        counterparty_name = row["Counterparty"]&.strip
        unless counterparty_name.present? && RpMaster.where(name: counterparty_name, active: true).exists?
          errors << "Row #{i}: Counterparty '#{counterparty_name}' not found in active RP Master"
          next
        end

        nature_val = row["Nature of Transaction"]&.strip
        sub_nature_val = row["Sub-Nature of Transaction"]&.strip
        txn_type_val = row["Type of Transaction"]&.strip

        unless Transaction.exists?(nature: nature_val)
          errors << "Row #{i}: Nature '#{nature_val}' not found in Transactions master"
          next
        end

        unless Transaction.exists?(nature: nature_val, sub_type: sub_nature_val)
          errors << "Row #{i}: Sub-Nature '#{sub_nature_val}' not found for Nature '#{nature_val}'"
          next
        end

        unless Transaction.exists?(nature: nature_val, sub_type: sub_nature_val, transaction_type: txn_type_val)
          errors << "Row #{i}: Type '#{txn_type_val}' not found for Nature '#{nature_val}' / Sub-Nature '#{sub_nature_val}'"
          next
        end

        master_txn = Transaction.find_by(nature: nature_val, sub_type: sub_nature_val, transaction_type: txn_type_val)

        if mode == "upsert"
          txn = RpTransaction.find_or_initialize_by(
            reporting_entity: entity,
            reporting_unit: unit,
            period: period,
            counterparty: counterparty_name,
            nature: nature_val,
            sub_nature: sub_nature_val,
            transaction_type: txn_type_val
          )
          is_new = txn.new_record?
          txn.amount = row["Amount"]
          txn.main_code = master_txn&.main_code
          txn.sub_code = master_txn&.sub_code
          txn.ic_code = master_txn&.ic_code
        else
          txn = RpTransaction.new(
            reporting_entity: entity,
            reporting_unit: unit,
            period: period,
            counterparty: counterparty_name,
            transaction_type: txn_type_val,
            nature: nature_val,
            sub_nature: sub_nature_val,
            amount: row["Amount"],
            main_code: master_txn&.main_code,
            sub_code: master_txn&.sub_code,
            ic_code: master_txn&.ic_code
          )
          is_new = true
        end

        if txn.save
          is_new ? created += 1 : updated += 1
        else
          errors << "Row #{i}: #{txn.errors.full_messages.join(', ')}"
        end
      end

      msg = "#{created} created, #{updated} updated."
      if errors.empty?
        redirect_to rp_transactions_path, notice: msg
      else
        redirect_to bulk_upload_rp_transactions_path, alert: "#{msg} #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def sample
    require "csv"
    csv_data = CSV.generate do |csv|
      csv << ["Reporting Entity", "Reporting Unit", "Period", "Counterparty", "Nature of Transaction", "Sub-Nature of Transaction", "Type of Transaction", "Amount", "Main Code", "Sub Code"]
      csv << ["Sample Entity", "Sample Unit", "April", "Sample Name", "Asset", "Investment", "Purchase", "10000", "MC01", "SC01"]
    end
    send_data csv_data, filename: "rp_transactions_sample.csv", type: "text/csv"
  end

  def export
    require "csv"
    records = RpTransaction.includes(:reporting_entity, :reporting_unit, :period).order(created_at: :desc)
    records = records.where(reporting_entity_id: params[:reporting_entity_id]) if params[:reporting_entity_id].present?
    records = records.where(reporting_unit_id: params[:reporting_unit_id]) if params[:reporting_unit_id].present?
    records = records.where(period_id: params[:period_id]) if params[:period_id].present?

    csv_data = CSV.generate do |csv|
      csv << ["Reporting Entity", "Reporting Unit", "Period", "Counterparty", "Nature of Transaction", "Sub-Nature of Transaction", "Type of Transaction", "Amount", "Main Code", "Sub Code"]
      records.each do |txn|
        csv << [
          txn.reporting_entity.name, txn.reporting_unit.name,
          txn.period.month, txn.counterparty,
          txn.nature, txn.sub_nature, txn.transaction_type, txn.amount,
          txn.main_code, txn.sub_code
        ]
      end
    end
    send_data csv_data, filename: "rp_transactions_export_#{Date.today}.csv", type: "text/csv"
  end

  def reporting_units
    units = ReportingUnit.where(reporting_entity_id: params[:reporting_entity_id])
    render json: units.select(:id, :name)
  end

  def sub_natures
    items = Transaction.active.where(nature: params[:nature]).distinct.pluck(:sub_type).compact
    render json: items
  end

  def transaction_types
    items = Transaction.active.where(nature: params[:nature], sub_type: params[:sub_type]).distinct.pluck(:transaction_type).compact
    render json: items
  end

  def transaction_codes
    scope = Transaction.active.where(nature: params[:nature], sub_type: params[:sub_type])
    scope = scope.where(transaction_type: params[:transaction_type]) if params[:transaction_type].present?
    txn = scope.first
    if txn
      render json: { main_code: txn.main_code, sub_code: txn.sub_code, ic_code: txn.ic_code }
    else
      render json: { main_code: nil, sub_code: nil, ic_code: nil }
    end
  end

  private

  def rp_transaction_params
    params.require(:rp_transaction).permit(:reporting_entity_id, :reporting_unit_id, :period_id,
                                           :counterparty, :transaction_type, :nature, :sub_nature, :amount, :main_code, :sub_code, :ic_code)
  end
end
