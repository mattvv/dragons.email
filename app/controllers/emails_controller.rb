class EmailsController < ApplicationController
  def create
    params[:email] = params[:email].downcase
    @email = Email.create(params[:email].permit(:list_id, :email, :name))
    redirect_to :back
  end

  def destroy
    @email = Email.find(params[:id])
    @email.destroy
    redirect_to :back
  end
end
