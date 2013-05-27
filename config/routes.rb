Shakespeare::Application.routes.draw do

  get "admin/index"

  match '/admin', :controller => 'admin', :action => 'index'

  namespace :admin do
    resources :relation_types
  end

  get "mdms/index"

  scope '(:locale)' do

    match '/relation_type_selected', :controller => 'relations', :action => 'relation_type_selected'

    match 'poems/mc_navigate', :controller => 'poems', :action => 'mc_navigate'
    resources :poems
    resources :values
    resources :relations

    root :to => 'poems#index', :as => 'mdms'
  end

end
