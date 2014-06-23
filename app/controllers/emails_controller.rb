class EmailsController < ApplicationController
  def create
    @email = Email.create(params[:email].permit(:list_id, :email, :name))
    redirect_to :back
  end

  def destroy
    @email = Email.find(params[:id])
    @email.destroy
    redirect_to :back
  end
end
