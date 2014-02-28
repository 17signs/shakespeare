class ApplicationController < ActionController::Base
  before_filter :set_i18n_locale_from_params
  protect_from_forgery

  protected
    def set_i18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.include?(params[:locale].to_sym)
          I18n.locale = params[:locale]
        else
          flash.now[:notice] = "#{params[:locale]} translation not available"
          logger.error flash.now[:notice]
        end
      end
    end

    def default_url_options
      { :locale => I18n.locale }
    end

  private

    # returns the lineage associated to the active session
    # if this lineage could not be found
    # a) the older ones are deleted
    # b) a new one is created and associated to the session

    def current_lineage
      Lineage.find_by_id!(session[:lineage_id])
    rescue MongoMapper::DocumentNotFound
      # Destroy old (1 hour) lineage information
      limit = Time.now - 3600
      Lineage.where({:updated_at => {'$lt' => limit}}).each do |old|
        old.destroy
      end

      lineage = Lineage.create
      lineage.nodes = Hash.new
      lineage.edges = []
      lineage.save
      session[:lineage_id] = lineage.id
      lineage
    end

end
