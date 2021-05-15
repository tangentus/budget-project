class TransactionsController < ApplicationController
  attr_reader :transaction, :transactions, :splits
  helper_method :transaction, :transactions, :splits

  before_action :set_transaction, only: %i[ show edit update destroy ]

  # GET /transactions or /transactions.json
  def index
    @transactions = Transaction.all
  end

  # GET /transactions/1 or /transactions/1.json
  def show
  end

  # GET /transactions/new
  def new
    @transaction = Transaction.new
    @splits = [transaction.splits.new]
  end

  # GET /transactions/1/edit
  def edit
    @splits = transaction.splits
  end

  # POST /transactions or /transactions.json
  def create
    @transaction = Transaction.new(transaction_params)

    render_errors and return unless transaction.save

    transaction.splits.create(split_charges_params)

    respond_to do |format|
      format.html { redirect_to transaction, notice: "Transaction was successfully created." }
      format.json { render :show, status: :created, location: transaction }
    end
  end

  # PATCH/PUT /transactions/1 or /transactions/1.json
  def update
    transaction_saved = transaction.update(transaction_params)
    splits_saved = transaction.splits.first.update(split_charges_params) if transaction_saved

    respond_to do |format|
      if transaction_saved && splits_saved
        format.html { redirect_to transaction, notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /transactions/1 or /transactions/1.json
  def destroy
    transaction.destroy
    respond_to do |format|
      format.html { redirect_to transactions_url, notice: "Transaction was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_transaction
      @transaction = Transaction.find(params[:id])
      @splits = transaction.splits
    end

    # Only allow a list of trusted parameters through.
    def transaction_params
      params[:transaction].permit(:type, :amount, :description, :processed_at)
    end

    def split_charges_params
      params[:transaction].require(:transaction_split).permit(:allowance, :amount)
    end

    def render_errors
      respond_to do |format|
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: transaction.errors, status: :unprocessable_entity }
      end
    end
end
