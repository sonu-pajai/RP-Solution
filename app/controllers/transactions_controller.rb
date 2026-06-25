class TransactionsController < ApplicationController
  load_and_authorize_resource except: [:bulk_upload, :template]

  def index
    @transactions = Transaction.order(:nature, :transaction_type)
  end

  def new
    @transaction = Transaction.new
  end

  def create
    @transaction = Transaction.new(transaction_params)
    if @transaction.save
      redirect_to transactions_path, notice: "Transaction created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @transaction = Transaction.find(params[:id])
  end

  def update
    @transaction = Transaction.find(params[:id])
    if @transaction.update(transaction_params)
      redirect_to transactions_path, notice: "Transaction updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transaction = Transaction.find(params[:id])
    @transaction.destroy
    redirect_to transactions_path, notice: "Transaction deleted."
  end

  def bulk_upload
    if request.post?
      file = params[:file]
      if file.blank?
        redirect_to bulk_upload_transactions_path, alert: "Please select a file."
        return
      end

      require "csv"
      count = 0
      errors = []

      CSV.foreach(file.path, headers: true).with_index(2) do |row, line|
        txn = Transaction.new(
          nature: row["Nature"]&.strip,
          transaction_type: row["Transaction Type"]&.strip,
          sub_type: row["Sub Type"]&.strip,
          as18: row["AS-18"]&.strip,
          acb: row["ACB"]&.strip,
          sebi: row["SEBI"]&.strip
        )
        txn.save ? count += 1 : (errors << "Row #{line}: #{txn.errors.full_messages.join(', ')}")
      end

      if errors.empty?
        redirect_to transactions_path, notice: "#{count} records uploaded."
      else
        redirect_to bulk_upload_transactions_path, alert: "#{count} created. #{errors.size} skipped. #{errors.first(5).join(' | ')}"
      end
    end
  end

  def template
    require "csv"
    csv_data = CSV.generate { |csv| csv << ["Nature", "Transaction Type", "Sub Type", "AS-18", "ACB", "SEBI"] }
    send_data csv_data, filename: "transactions_template.csv", type: "text/csv"
  end

  private

  def transaction_params
    params.require(:transaction).permit(:nature, :transaction_type, :sub_type, :as18, :acb, :sebi)
  end
end
