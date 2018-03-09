# Triggers controller class
class TriggersController < ApplicationController
  def index
    @triggers = Trigger.cached_all.select { |trigger| trigger.email ==  Trigger.get_email}
  end

  def new
    @trigger = Trigger.new
  end

  def show
    @triggers = Trigger.cached_all.select { |trigger| trigger.email == Trigger.get_email }
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def create
    @triggers = Trigger.cached_all.select { |trigger| trigger.email == Trigger.get_email }
    @trigger = Trigger.new(trigger_params)
    if @trigger.save
      respond_to { |format| format.html { redirect_to root_path } }
    else
      respond_to do |format|
        format.html { redirect_to root_path }
        format.js
      end
    end
  end

  def update
    Trigger.set_email(trigger_params[:email])
    @triggers = Trigger.cached_all.select { |trigger| trigger.email == Trigger.get_email }
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def destroy
    @trigger = Trigger.destroy(params[:id])
    @triggers = Trigger.cached_all.select { |trigger| trigger.email == Trigger.get_email }
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
