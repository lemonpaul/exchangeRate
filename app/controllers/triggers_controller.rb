class TriggersController < ApplicationController

  def index
    @triggers = Trigger.cahced_all
  end

  def new
    @trigger = Trigger.new
  end

  def show
    @triggers = Trigger.cached_all
    puts trigger_params[:email]
    @triggers = @triggers.select{|trigger| trigger.email = trigger_params[:email]}
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def create
    @triggers = Trigger.cached_all
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
