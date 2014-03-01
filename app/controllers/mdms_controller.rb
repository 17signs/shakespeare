class MdmsController < ApplicationController
  def index
    if params[:set_locale]
      redirect_to mdms_path(:locale => params[:set_locale])
    else
    end
  end
end
