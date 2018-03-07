class TriggersController < ApplicationController

  def index
    @triggers = Trigger.all
  end

  def new
    @trigger = Trigger.new
  end

  def create
    @triggers = Trigger.all
    @trigger = Trigger.new(trigger_params)

    if @trigger.save
      respond_to do |format|
        format.html { redirect_to root_path }
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    end
  end
 
  def destroy
    @trigger = Trigger.destroy(params[:id])
    @triggers = Trigger.all
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  private
    def trigger_params
      params.require(:trigger).permit(:email, :currency, :operation, :kind, :rate)
    end
end
