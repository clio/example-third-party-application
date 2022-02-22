class WelcomeController < ApplicationController

  def index
    cookies.encrypted[:install_flow] = params[:install_flow]
  end

end
