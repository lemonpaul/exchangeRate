# Welcome controller class
class WelcomeController < ApplicationController
  before_action :init_values

  def init_values
    @triggers = Trigger.select_email
    Rate.sorted.empty? && AddRateJob.perform_now
    @rates = Rate.sorted
  end

  def show
    respond_to { |format| format.js }
  end
end
