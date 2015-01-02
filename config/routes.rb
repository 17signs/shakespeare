Shakespeare::Application.routes.draw do

  get 'mdms/index'

  scope '(:locale)' do

    match '/relation_type_selected', :controller => 'relations', :action => 'relation_type_selected'

    match 'poems/to_poems', :controller => 'poems', :action => 'to_poems'

    resources :poems
    resources :values
    resources :relations

    match 'lineages/index', :controller => 'lineage', :action => 'index'
    resources :lineages

    root :to => 'poems#index', :as => 'mdms'
  end

end
