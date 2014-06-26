class EmailsController < ApplicationController
  def index
    @emails = Email.all
    @email = Email.new
  end

  def create
    if params[:email][:list_id]
      list = List.find(params[:email].delete(:list_id))
      @email = Email.find(params[:email][:email])
      @email.lists << list
    else
      params[:email][:email].downcase!
      @email = Email.new(params[:email].permit(:email, :name))
    end

    @email.save

    redirect_to :back
  end

  def destroy
    @email = Email.find(params[:id])
    if params[:list_id].nil?
      @email.destroy
    else
      list = List.find(params[:list_id])
      list.emails.delete(@email)
    end
    redirect_to :back
  end
end
