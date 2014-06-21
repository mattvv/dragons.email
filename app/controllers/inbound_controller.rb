class InboundController < ApplicationController
  def create
    puts 'Inbound Email'

    render json: {}
  end
end
