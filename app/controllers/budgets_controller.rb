class BudgetsController < ApplicationController
  attr_reader :budgets, :budget
  helper_method :budgets, :budget

  before_action :set_budget, only: %i[ show edit update destroy ]

  def index
    @budgets = Budget.all
  end

  def show
  end

  def new
    @budget = Budget.new
  end

  def create
    @budget = Budget.new(budget_params)

    if budget.save
      respond_to do |format|
        format.html { redirect_to budget, notice: "Budget was successfully created." }
        format.json { render :show, status: :created, location: budget }
      end
    end
  end

  def edit
  end

  def update
    respond_to do |format|
      if budget.update(budget_params)
        format.html { redirect_to transaction, notice: "Transaction was successfully updated." }
        format.json { render :show, status: :ok, location: transaction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    budget.destroy
    respond_to do |format|
      format.html { redirect_to budgets_url, notice: "Budget was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_budget
    @budget = Budget.find(params[:id])
  end

  def budget_params
    params.require(:budget).permit(:name, :start_date, :end_date)
  end
end
