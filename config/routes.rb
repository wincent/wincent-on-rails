Wincent::Application.routes.draw do |map|
  resources :attachments
  resources :comments
  resources :confirmations, :path => 'confirm'

  resources :issues do
    resources :comments
    collection do
      get :search
      post :search
      get 'page/:page' => 'issues#index'
    end
  end

  resources :links
  resources :products do
    resources :pages
  end
  resources :sessions
  resources :taggings
  resources :resets

  resources :tweets, :path => 'twitter' do
    resources :comments
    collection do
      get 'page/:page' => 'tweets#index'
    end
  end

  resources :searches,
            :only => [ :create, :new ],
            :path => 'search'
  get '/search' => 'searches#new' # anticipate users who might guess this URL

  # mapping to "product_page" would overwrite the nested RESTful route above
  match '/products/:id/:page_id' => 'products#show',
        :via => :get,
        :as => 'embedded_product_page'


  # must explicitly allow period in the id part of the route otherwise it
  # will be classified as a route separator
  resources :posts, :path => 'blog', :id => /[a-z0-9\-\.]+/ do
    resources :comments
    collection do
      get 'page/:page' => 'posts#index'
    end
  end

  resources :forums do
    resources :topics do
      resources :comments
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
    resources :comments
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
    resources :forums
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
