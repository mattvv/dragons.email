class InboundController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    puts 'Inbound Email'

    render json: {}
  end
end
