class ListsController < ApplicationController
  def index
    @lists = List.all

    @list = List.new
  end

  def create
    unless params[:list][:email].include? '@dragons.email'
      params[:list][:email] = "#{params[:list][:email]}@dragons.email"
    end

    if List.create(params[:list].permit(:email))
      flash[:success] = 'Created List'
    else
      flash[:error] = 'Could not create list'
    end


    redirect_to :back
  end

  def show
    @list = List.find(params[:id])
    @email = Email.new
  end
end
