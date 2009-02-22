ActionController::Routing::Routes.draw do |map|

  # resources
  # TODO: may be able to clean some of these routes up using :shallow and :only from Rails 2.2
  map.with_options :requirements => { :protocol => 'https' } do |https|
    https.resources :comments
    https.resources :confirmations, :as => :confirm
    https.resources :issues,
                    :has_many => [ :comments ],
                    :collection => { :search => :get }
    https.resources :links
    https.resources :products
    https.resources :sessions
    https.resources :taggings
    https.resources :resets

    # not a real resource, but declaring it as such gives us some convenient routing helpers
    https.resources :search, :collection => { :issues => :get }
  end

  # must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :posts,
                :as => :blog,
                :requirements => { :id => /[a-z0-9\-\.]+/, :protocol => 'https' },
                :has_many => [ :comments ]

  map.resources :forums, :requirements => { :protocol => 'https' } do |forum|
    forum.resources :topics,
                    :requirements => { :protocol => 'https' },
                    :has_many => [ :comments ]
  end

  # avoid some N+1 SELECT problems by allowing unnested links to forum topics
  # (useful, for example, when displaying search results; no need to lookup forum from db)
  # ie. /topics/12/ will redirect to /forum/foo/topic/12/ only if the user clicks on link
  map.resources :topics, :only => [ :index, :show ], :requirements => { :protocol => 'https' }

  # must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :tags,
                :requirements => { :id => /[a-z\.]+/, :protocol => 'https' },
                :collection => { :search => :get }

  map.resources :users, :requirements => { :protocol => 'https' }  do |user|
    user.resources :emails, :requirements => { :id => /[^\/]+/, :protocol => 'https' }
  end

  # again, must explicitly allow period in the id part of the route otherwise it will be classified as a route separator
  map.resources :articles,
                :as => :wiki,
                :requirements => { :id => /[^\/]+/, :protocol => 'https' },
                :has_many => [ :comments ]

  # this gives us pagination URLs like: /wiki/page/3
  # instead of: /wiki?page=3
  # note that an article called "page" can still be accessed at: /wiki/page
  map.paginated_articles '/wiki/page/:page', :controller => 'articles', :action => 'index', :protocol => 'https'

  # regular routes
  # note that we cannot specify :protocol here without breaking the url_for method
  # must pass an explicit :protocol whenever using url_for
  map.connect 'misc/:action', :controller => 'misc'

  map.with_options :protocol => 'https' do |https|
    # named routes
    https.admin_dashboard 'admin/dashboard',  :controller => 'admin/dashboard', :action => 'show'
    https.dashboard       'dashboard',        :controller => 'dashboard',       :action => 'show'
    https.login           'login',            :controller => 'sessions',        :action => 'new'
    https.logout          'logout',           :controller => 'sessions',        :action => 'destroy'
    https.support         'support',          :controller => 'support'
  end

  # although conditionally inlining admin functionality in the standard resources is elegant
  # it makes page caching difficult because the page looks different for admin users
  # so we provide a separate admin interface for some resources
  map.namespace :admin do |admin|
    admin.with_options :requirements => { :protocol => 'https' } do |https|
      https.resources :forums
      https.resources :issues
      https.resources :posts
      https.resources :tags
    end
  end

  map.with_options :protocol => 'https' do |https|
    #https.root :controller => 'products' # action defaults to index
    https.root :controller => 'posts' # temporary only
  end

  # the default routes, at lowest priority, needed for AJAX in-place editing
  # the alternative is to specify explicit ":member" or ":collection" parameters above,
  # which won't work as soon as you start nesting resources
  # NOTE: cannot specify :protocol => 'https' here (breaks url_for)
  #       so _must_ be stringent about explicitly specifying https whenever using url_for
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
