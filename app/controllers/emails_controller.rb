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

  def update
    params[:email][:email].downcase! if params[:email][:email]
    @email = Email.find(params[:id])


    respond_to do |format|
      if @email.update_attributes(params[:email].permit(:phone_number, :notes, :email, :name))
        format.html { redirect_to :back, notice: 'Email was successfully updated.' }
        format.json { head :no_content } # 204 No Content
      else
        format.html { redirect_to :back }
        format.json { render json: @email.errors, status: :unprocessable_entity }
      end
    end
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
