class MdmsController < ApplicationController
  def index
    if params[:set_locale]
      redirect_to mdms_path(:locale => params[:set_locale])
    else
      # miller column navigation
      $mc = nil
      $mc_selected = []
      Poem.navigate()
    end
  end
end
