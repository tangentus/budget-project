class ApplicationController < ActionController::Base
  before_action :set_session_budget

  private

  def set_session_budget
    Budget.current_budget = Budget.where(start_date: {"$gte": DateTime.now}).first
  end
end
