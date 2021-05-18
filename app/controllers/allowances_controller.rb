class AllowancesController < ApplicationController
  attr_reader :allowance, :allowances
  helper_method :allowance, :allowances

  before_action :set_allowance, only: %i[ show edit update destroy ]

  # GET /allowances or /allowances.json
  def index
    @allowances = Allowance.all
  end

  # GET /allowances/1 or /allowances/1.json
  def show
  end

  # GET /allowances/new
  def new
    @allowance = Allowance.new
    @splits = [allowance.splits.new]
  end

  def create
    @allowance = Allowance.new(allowance_params)

    if allowance.save
      respond_to do |format|
        format.html { redirect_to allowance, notice: "Allowance was successfully created." }
        format.json { render :show, status: :created, location: allowance }
      end
    end
  end

  # GET /allowances/1/edit
  def edit
  end

  # PATCH/PUT /allowances/1 or /allowances/1.json
  def update
    respond_to do |format|
      if allowance.update(allowance_params)
        format.html { redirect_to allowance, notice: "Allowance was successfully updated." }
        format.json { render :show, status: :ok, location: allowance }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: allowance.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /allowances/1 or /allowances/1.json
  def destroy
    allowance.destroy
    respond_to do |format|
      format.html { redirect_to allowances_url, notice: "Allowance was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def set_allowance
    @allowance = Allowance.find(params[:id])
  end

  def allowance_params
    params.require(:allowance).permit(:name, :starting_amount, :planned, :category, :start_date, :end_date)
  end
end
