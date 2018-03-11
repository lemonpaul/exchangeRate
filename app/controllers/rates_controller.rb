# Rates controller class
class RatesController < ApplicationController
  def destroy
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end
end
