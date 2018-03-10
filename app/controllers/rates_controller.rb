# Rates controller class
class RatesController < ApplicationController
  before_action :init_values

  def init_values
    @rates = Rate.all
  end

  def destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
