class InboundControllerController < ApplicationController
  def create
    puts 'Inbound Email'

    render json: {}
  end
end
