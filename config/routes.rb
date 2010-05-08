Wincent::Application.routes.draw do |map|
  constraints :protocol => 'https' do
    resources :attachments
    resources :comments
    resources :confirmations, :path => 'confirm'

    resources :issues do
      resources :comments
      collection do
        get :search
        post :search
      end
    end
    match '/issues/page/:page' => 'issues#index', :as => 'paginated_issues'

    resources :links
    resources :products do
      resources :pages
    end
    resources :sessions
    resources :taggings
    resources :resets

    resources :tweets, :path => 'twitter' do
      resources :comments
    end
    match '/twitter/page/:page' => 'tweets#index', :as => 'paginated_tweets'

    resources :searches,
              :only => [ :create, :new ],
              :path => 'search'

    # mapping to "product_page" would overwrite the nested RESTful route above
    match '/products/:id/:page_id' => 'products#show',
          :via => :get,
          :as => 'embedded_product_page'


    # must explicitly allow period in the id part of the route otherwise it
    # will be classified as a route separator
    resources :posts, :path => 'blog', :id => /[a-z0-9\-\.]+/ do
      resources :comments
    end
    match '/blog/page/:page' => 'posts#index', :as => 'paginated_posts'

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
    end

    # this gives us pagination URLs like: /wiki/page/3
    # instead of: /wiki?page=3
    # note that an article called "page" can still be accessed at: /wiki/page
    match 'wiki/page/:page' => 'articles#index',
          :as => 'paginated_articles',
          :page => %r{\d+}

    # regular routes
    match 'l/:id'           => 'links#show'
    match 'misc/:action'    => 'misc'
    match 'heartbeat/ping'
    match 'js/:delegated'   => 'js#show', :delegated => %r{([a-z_]+/)+[a-z_]+}

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

    root :to => 'posts#index'     # now
    #root :to => 'products#index' # later
  end
end
