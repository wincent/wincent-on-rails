ActionController::Routing::Routes.draw do |map|

  # resource routes
  map.resources :comments
  map.resources :emails do |email|
    email.resources :confirm, :controller => 'confirmations'
  end
  map.resources :issues
  map.resources :links

  # later this will be map.resources :posts, :as => :blog
  # (see comment for wiki/articles controller)
  # must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :blog, :requirements => { :id => /[a-z0-9\-\.]+/ }, :controller => 'posts', :has_many => [ :comments ]

  map.resources :forums do |forum|
    forum.resources :topics, :has_many => [ :comments ]
  end

  map.resources :products
  map.resources :sessions

  # must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :tags, :requirements => { :id => /[a-z\.]+/ }, :collection => { :search => :get }

  map.resources :taggings
  map.resources :users

  # the wiki is built on the Article model, but we want routes like /wiki/Article%20Title, not /article/1
  # for now doing it using an explicit :controller
  # with next Rails release will be able to use:
  #   map.resources :articles, :as => :wiki
  # which will be nice because I'll have helper methods like "new_article_path" instead of "new_wiki_path"
  # will also fix the AtomFeedHelper breakage (polymorphic_url won't work with these kinds of routes)
  # again, must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :wiki,    :requirements => { :id => /[^\/]+/ }, :controller => 'articles',  :has_many => [ :comments ]

  # regular routes
  map.connect   'misc/:action', :controller => 'misc'

  # named routes
  map.login     'login',  :controller => 'sessions',  :action => 'new'
  map.logout    'logout', :controller => 'sessions',  :action => 'destroy'
  map.home      '',       :controller => 'products'   # action defaults to index

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
