Wincent::Application.routes.draw do
  get ':id',
    id: ShortLink::SHORT_LINK_REGEX,
    constraints: { domain: APP_CONFIG['short_link_host'] },
    to: 'short_links#show'

  # must explicitly allow period in the id part of the route
  # otherwise it will be classified as a route separator
  resources :articles, id: /[^\/]+/ , path: 'wiki' do
    collection do
      get 'page/:page' => 'articles#index', :page => %r{\d+}
    end
  end

  resources :comments, except: %i[create new update]

  resources :links

  # must explicitly allow period in the id part of the route otherwise it
  # will be classified as a route separator
  resources :posts, path: 'blog', id: /[a-z0-9\-\.]+/ do
    collection do
      get 'page/:page' => 'posts#index', :page => %r{\d+}
    end
  end

  resources :products do
    resources :pages, except: %i[index show]
  end

  # mapping to "product_page" would overwrite the nested RESTful route above
  get 'products/:id/:page_id' => 'products#show',
      :as => 'embedded_product_page'

  get 'repos', to: redirect('https://github.com/wincent')
  get 'repos/*rest', to: redirect('https://github.com/wincent')

  resources :resets
  resources :sessions, only: %i[new create destroy]

  resources :snippets do
    collection do
      get 'page/:page' => 'snippets#index', :page => %r{\d+}
    end
  end

  resources :taggings

  # must explicitly allow period in the id part of the route otherwise
  # it will be classified as a route separator
  resources :tags, id: /[a-z0-9\.]+/ do
    collection do
      get :search
    end
  end

  get 'twitter', to: redirect(APP_CONFIG['twitter_url'])
  get 'twitter/*rest', to: redirect(APP_CONFIG['twitter_url'])

  resources :users, only: %i[index show] do
    resources :emails, id: /[^\/]+/
  end

  # although conditionally inlining admin functionality in the standard
  # resources is elegant it makes page caching difficult because the page
  # looks different for admin users so we provide a separate admin interface
  # for some resources
  namespace :admin do
    resources :issues
    resources :posts
    resources :tags
    get 'dashboard' => 'dashboard#show'
  end

  get 'dashboard'       => 'dashboard#show'
  get 'heartbeat/ping'

  get 'l/:id'           => 'links#show'
  get 'login'           => 'sessions#new'
  get 'logout'          => 'sessions#destroy'
  get 'misc/:action'    => 'misc'
  get 'search', to: redirect('https://www.google.com/#q=site:wincent.com')
  get 'support', to: redirect('/issues')

  root :to => 'posts#index'
end
