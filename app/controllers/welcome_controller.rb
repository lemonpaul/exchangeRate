# Welcome controller class
class WelcomeController < ApplicationController
  before_action :init_values

  def init_values
    @triggers = Trigger.select_email
    Rate.all.empty? && AddRateJob.perform_now
    @rates = Rate.all
  end

  def show
    puts '---------------------------------------------------------------------'
    puts Trigger.email
    respond_to { |format| format.js }
  end
end
