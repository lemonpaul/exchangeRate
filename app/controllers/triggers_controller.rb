# Triggers controller class
class TriggersController < ApplicationController
  before_action :init_triggers, only: %i[index show create]

  def init_triggers
    @triggers = Trigger.select_email
  end

  def new
    @trigger = Trigger.new
  end

  def show
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def create
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
    Trigger.email = trigger_params[:email]
    @triggers = Trigger.all
                       .select { |trigger| trigger.email == Trigger.email }
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js
    end
  end

  def destroy
    @trigger = Trigger.destroy(params[:id])
    @triggers = Trigger.select_email
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
