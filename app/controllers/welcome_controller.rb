# Welcome controller class
class WelcomeController < ApplicationController
  before_action :init_values

  def init_values
    @triggers = Trigger.all
                       .select { |trigger| trigger.email == Trigger.email }
    @rates = Rate.all
    @counts = Rate.counts
    @today_rates = Rate.today
    @current_rates = Rate.current
  end

  def show
    respond_to { |format| format.js }
    sleep 5
  end
end
