class TransactionsController < ApplicationController
  load_and_authorize_resource

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

  private

  def transaction_params
    params.require(:transaction).permit(:nature, :transaction_type, :sub_type, :as18, :acb, :sebi)
  end
end
