ActionController::Routing::Routes.draw do |map|

  # resources
  map.resources :comments
  map.resources :confirm, :controller => 'confirmations'
  map.resources :issues, :has_many => [ :comments ], :collection => { :search => :post }
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
  map.resources :users do |user|
    user.resources :emails, :requirements => { :id => /[^\/]+/ }
  end
  map.resources :resets

  # the wiki is built on the Article model, but we want routes like /wiki/Article_title, not /article/1
  # for now doing it using an explicit :controller
  # with next Rails release will be able to use:
  #   map.resources :articles, :as => :wiki
  # which will be nice because I'll have helper methods like "new_article_path" instead of "new_wiki_path"
  # will also fix the AtomFeedHelper breakage (polymorphic_url won't work with these kinds of routes)
  # again, must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :wiki,    :requirements => { :id => /[^\/]+/ }, :controller => 'articles',  :has_many => [ :comments ]

  # regular routes
  map.connect   'misc/:action',   :controller => 'misc'
  map.connect   'search/:action', :controller => 'search'

  # named routes
  map.admin_dashboard 'admin/dashboard',  :controller => 'admin/dashboard', :action => 'show'
  map.dashboard       'dashboard',        :controller => 'dashboard',       :action => 'show'
  map.login           'login',            :controller => 'sessions',        :action => 'new'
  map.logout          'logout',           :controller => 'sessions',        :action => 'destroy'
  map.support         'support',          :controller => 'support'

  # although conditionally inlining admin functionality in the standard resources is elegant
  # it makes page caching difficult because the page looks different for admin users
  # so we provide a separate admin interface for some resources
  map.namespace :admin do |admin|
    # TODO: make admin-only dashboard as well (overview of items awaiting moderation)
    admin.resources :forums
    admin.resources :issues
    admin.resources :posts
    admin.resources :tags
  end

  #map.root :controller => 'products' # action defaults to index
  map.root :controller => 'posts' # temporary only

  # the default routes, at lowest priority, needed for AJAX in-place editing
  # the alternative is to specify explicit ":member" or ":collection" parameters above,
  # which won't work as soon as you start nesting resources
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
