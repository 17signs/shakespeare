class MdmsController < ApplicationController
  def index
    @poems = Poem.search(params[:search], params[:advanced_search]||nil)
  end
end
