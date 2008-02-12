ActionController::Routing::Routes.draw do |map|

  # resource routes
  map.resources :comments
  map.resources :emails
  map.resources :issues
  map.resources :links
  map.resources :locales, :has_many => [ :translations ]
  map.resources :sessions
  map.resources :statuses
  map.resources :tags
  map.resources :taggings
  map.resources :users

  # the wiki is built on the Article model, but we want routes like /wiki/Article%20Title, not /article/1
  # for now doing it using an explicit :controller
  # with next Rails release will be able to use:
  #   map.resources :articles, :as => :wiki
  # BUG: not all routes work; eg. this gives us a routing error ("No route matches")
  #     /wiki/Upgrading%20to%20Git%201.5.2.4%20on%20Red%20Hat%20Enterprise%20Linux
  # but this works fine:
  #     /wiki/Setting%20up%20the%20Git%20documentation%20build%20chain%20on%20Mac%20OS%20X%20Leopard
  map.resources :wiki,    :controller => 'articles',  :has_many => [ :comments ]

  # named routes
  map.login     'login',  :controller => 'sessions',  :action => 'new'
  map.logout    'logout', :controller => 'sessions',  :action => 'destroy'
  map.home      '',       :controller => 'users'      # defaults to index

  map.namespace :admin do |admin|
    admin.resources :tags
  end

  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # the default routes, at lowest priority, needed for AJAX in-place editing
  # the alternative is to specify explicit ":member" parameters above
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
