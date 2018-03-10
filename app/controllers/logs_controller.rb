# History controller class
class LogsController < ApplicationController
  before_action :init_values

  def init_values
    Rate.all.empty? && AddRateJob.perform_now
    @rates = Rate.all
  end

  def destroy
    Rate.destroy(params[:id])
    Rate.all.empty? && AddRateJob.perform_now
    @rates = Rate.all
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def update
    Rate.sort_type = params[:sort_type]
    Rate.currency_filter = params[:currency_filter]
    Rate.operation_filter = params[:operation_filter]
    Rate.order = params[:order]
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
