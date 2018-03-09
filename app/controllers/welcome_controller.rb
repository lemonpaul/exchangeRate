# Welcome controller class
class WelcomeController < ApplicationController
  before_action :init_values

  def init_values
    @triggers = Trigger.cached_all
                       .select { |trigger| trigger.email == Trigger.email }
    @rates = Rate.cached_all
    @today_rates = Rate.today
    @counts = Rate.counts
    @current_rates = Rate.current
  end

  def show
    respond_to { |format| format.js }
  end
end
