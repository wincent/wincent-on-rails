Wincent::Application.routes.draw do
  resources :attachments
  resources :comments
  resources :confirmations, :path => 'confirm'

  resources :issues do
    resources :comments, :only => [:create, :new]
    collection do
      get :search
      get 'page/:page' => 'issues#index', :page => %r{\d+}
    end
  end

  resources :links
  resources :products do
    resources :pages
  end
  resources :sessions
  resources :taggings

  resources :repos do
    # Rails BUG:
    #   https://rails.lighthouseapp.com/projects/8994/tickets/5513
    # fixed in this commit (post-3.0):
    #   http://github.com/rails/rails/commit/02480a897be25c24f59180513d37649a31ad3835
    # until 3.0.1 is released, need to work around this with an explicit
    # "nested" block:
    nested do
      # Git branch names can include pretty much anything, including slashes
      # and crazy stuff like leading dashes, but we adopt a more restrictive
      # model here: we insist that the branch name begin with a letter, a
      # number or an underscore, and the remainder of the branch name may be
      # any number of letters, numbers, underscores, hyphens, slashes or
      # periods.
      #
      # Note that this is way more liberal than most Rails resources, so it
      # means we can't do stuff like edit branches, but that's fine as they
      # are effectively a read-only resource.
      resources :branches, :id => %r{[a-z0-9_][a-z0-9./_-]*}i,
        :only => [:index, :show]

      resources :commits, :id => /[a-f0-9]{7,40}/,
        :only => [:index, :show]
    end
  end
  resources :resets
  resources :snippets do
    resources :comments, :only => [:create, :new ]
    collection do
      get 'page/:page' => 'snippets#index', :page => %r{\d+}
    end
  end

  resources :tweets, :path => 'twitter' do
    resources :comments, :only => [ :create, :new ]
    collection do
      get 'page/:page' => 'tweets#index', :page => %r{\d+}
    end
  end

  get '/search' => 'search#search'

  # mapping to "product_page" would overwrite the nested RESTful route above
  match '/products/:id/:page_id' => 'products#show',
        :via => :get,
        :as => 'embedded_product_page'


  # must explicitly allow period in the id part of the route otherwise it
  # will be classified as a route separator
  resources :posts, :path => 'blog', :id => /[a-z0-9\-\.]+/ do
    resources :comments, :only => [ :create, :new ]
    collection do
      get 'page/:page' => 'posts#index', :page => %r{\d+}
    end
  end

  resources :forums do
    resources :topics, :except => :index do
      resources :comments, :only => [ :create, :new ]
    end
  end

  # avoid some N+1 SELECT problems by allowing unnested links to forum
  # topics (useful, for example, when displaying search results; no need
  # to lookup forum from db) ie. /topics/12/ will redirect to
  # /forum/foo/topic/12/ only if the user clicks on link
  resources :topics, :only => [ :index, :show ]

  # must explicitly allow period in the id part of the route otherwise
  # it will be classified as a route separator
  resources :tags, :id => /[a-z0-9\.]+/ do
    collection do
      get :search
    end
  end

  resources :users do
    resources :emails, :id => /[^\/]+/
  end

  # again, must explicitly allow period in the id part of the route
  # otherwise it will be classified as a route separator
  resources :articles, :id => /[^\/]+/ , :path => 'wiki' do
    resources :comments, :only => [ :create, :new ]
    collection do
      get 'page/:page' => 'articles#index', :page => %r{\d+}
    end
  end

  # regular routes
  match 'l/:id'           => 'links#show'
  match 'misc/:action'    => 'misc'
  match 'heartbeat/ping'

  # explicit extension here to help nginx send correct Content-Type
  match 'js/:delegated'   => 'js#show',
        :delegated        => %r{([a-z_]+/)+[a-z_]+\.js}

  # named routes
  match 'about'           => 'misc#about'
  match 'dashboard'       => 'dashboard#show'
  match 'login'           => 'sessions#new'
  match 'logout'          => 'sessions#destroy'
  match 'support'         => 'support#index'

  # although conditionally inlining admin functionality in the standard
  # resources is elegant it makes page caching difficult because the page
  # looks different for admin users so we provide a separate admin interface
  # for some resources
  namespace :admin do
    match 'dashboard' => 'dashboard#show'
    resources :forums, :only => [ :index, :show, :update ]
    resources :issues
    resources :posts
    resources :tags

    # without this url_for() is broken in app/views/layouts in the admin
    # namespace
    # TODO: check that this is still the case in Rails 3
    match 'misc/:action' => 'misc'
  end

  root :to => 'products#index'
end
