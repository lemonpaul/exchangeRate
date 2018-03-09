# History controller class
class HistoryController < ApplicationController
  before_action :init_values

  def init_values
    Rate.cached_all.empty? && AddRateJob.perform_now
    @rates = Rate.cached_all
  end

  def destroy
    Rate.destroy(params[:id])
    Rate.cached_all.empty? && AddRateJob.perform_now
    @rates = Rate.cached_all
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
