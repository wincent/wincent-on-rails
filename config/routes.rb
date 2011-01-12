Wincent::Application.routes.draw do
  # must explicitly allow period in the id part of the route
  # otherwise it will be classified as a route separator
  resources :articles, :id => /[^\/]+/ , :path => 'wiki' do
    resources :comments, :only => [ :create, :new ]
    collection do
      # this and other RESTful pagination routes were broken by Rails 3.0.3
      # see Rails BUG: https://rails.lighthouseapp.com/projects/8994/tickets/6028
      # the workaround for now is to make the page parameter appear as optional
      get '(page/:page)' => 'articles#index', :page => %r{\d+}
    end
  end

  resources :attachments
  resources :comments
  resources :confirmations, :path => 'confirm'

  resources :forums do
    resources :topics, :except => :index do
      resources :comments, :only => [ :create, :new ]
    end
  end

  resources :issues do
    resources :comments, :only => [:create, :new]
    collection do
      get :search
      get '(page/:page)' => 'issues#index', :page => %r{\d+}
    end
  end

  resources :links
  resources :products do
    resources :pages
  end

  resources :repos do
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

    resources :commits, :id => /[a-f0-9]{4,40}/,
      :only => [:index, :show]

    # can't use "resources :tags", as we already have a TagsController
    resources :git_tags, :path => 'tags', :id => %r{[a-z0-9_][a-z0-9./_-]*}i,
      :only => [:index, :show]
  end

  resources :resets
  resources :sessions

  resources :snippets do
    resources :comments, :only => [:create, :new ]
    collection do
      get '(page/:page)' => 'snippets#index', :page => %r{\d+}
    end
  end

  resources :taggings
  resources :tweets, :path => 'twitter' do
    resources :comments, :only => [ :create, :new ]
    collection do
      get '(page/:page)' => 'tweets#index', :page => %r{\d+}
    end
  end

  # mapping to "product_page" would overwrite the nested RESTful route above
  get '/products/:id/:page_id' => 'products#show',
      :as => 'embedded_product_page'


  # must explicitly allow period in the id part of the route otherwise it
  # will be classified as a route separator
  resources :posts, :path => 'blog', :id => /[a-z0-9\-\.]+/ do
    resources :comments, :only => [ :create, :new ]
    collection do
      get '(page/:page)' => 'posts#index', :page => %r{\d+}
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

  # although conditionally inlining admin functionality in the standard
  # resources is elegant it makes page caching difficult because the page
  # looks different for admin users so we provide a separate admin interface
  # for some resources
  namespace :admin do
    resources :forums, :only => [ :index, :show, :update ]
    resources :issues
    resources :posts
    resources :tags
    get 'dashboard' => 'dashboard#show'
    # without this url_for() is broken in app/views/layouts in the admin
    # namespace
    # TODO: check that this is still the case in Rails 3
    get 'misc/:action' => 'misc'
  end

  get 'about'           => 'misc#about'
  get 'dashboard'       => 'dashboard#show'
  get 'heartbeat/ping'

  # explicit extension here to help nginx send correct Content-Type
  get 'js/:delegated'   => 'js#show',
      :delegated        => %r{([a-z_]+/)+[a-z_]+\.js}

  get 'l/:id'           => 'links#show'
  get 'login'           => 'sessions#new'
  get 'logout'          => 'sessions#destroy'
  get 'misc/:action'    => 'misc'
  get '/search'         => 'search#search'
  get 'support'         => 'support#index'

  root :to => 'products#index'
end
