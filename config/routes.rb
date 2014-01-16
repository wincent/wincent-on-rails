Wincent::Application.routes.draw do
  # must explicitly allow period in the id part of the route
  # otherwise it will be classified as a route separator
  resources :articles, id: /[^\/]+/ , path: 'wiki' do
    resources :comments, only: %i[create new update]
    collection do
      get 'page/:page' => 'articles#index', :page => %r{\d+}
    end
  end

  resources :attachments
  resources :comments, except: %i[create new update]
  resources :confirmations, path: 'confirm'

  resources :forums do
    resources :topics, except: :index
  end

  resources :issues do
    resources :comments, only: %i[create new update]
    collection do
      get :search
      get 'page/:page' => 'issues#index', :page => %r{\d+}
    end
  end

  resources :links

  # must explicitly allow period in the id part of the route otherwise it
  # will be classified as a route separator
  resources :posts, path: 'blog', id: /[a-z0-9\-\.]+/ do
    resources :comments, only: %i[create new update]
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
    resources :branches,
              id:   %r{[a-z0-9_][a-z0-9./_-]*}i,
              only: %i[index show]

    # Git is effectively a content-addressable storage system, so we could
    # retrieve blobs by the SHA-1 hash only; however, for a better user
    # experience we address blobs using the format "[commit-ish]:[path]", which
    # will yield URLs like:
    #
    #  https://wincent.com/repos/command-t/blobs/master:Gemfile
    #  https://wincent.com/repos/command-t/blobs/HEAD:Gemfile.lock
    #  https://wincent.com/repos/command-t/blobs/86e87abcd25:doc/command-t.txt
    #
    # This approach is similar to the one taken by Gitweb, and different from
    # GitHub (which uses the format "{blob,tree}/[commit-ish]/[path]"); I'd
    # prefer not to go down that route and have to disambiguate branch names
    # with slashes in them.
    resources :blobs, id: %r{[^:]+:[^:]+}, only: :show, format: false

    resources :commits, id: /[a-f0-9]{4,40}/, only: %i[index show]

    # See comments on the blobs resource above about why we're using this :id
    # format. The only difference from the blob format is that the path is
    # optional, in which case it defaults to the root of the tree.
    resources :trees, id: %r{[^:]+(:[^:]+)}, only: :show, format: false

    # can't use "resources :tags", as we already have a TagsController
    resources :git_tags,
              path: 'tags',
              id:   %r{[a-z0-9_][a-z0-9./_-]*}i,
              only: %i[index show]
  end

  resources :resets
  resources :sessions, only: %i[new create destroy]

  resources :snippets do
    resources :comments, only: %i[create new update]
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

  # use some shallow routes for convenience and to avoid some N+1 select
  # problems
  resources :topics, only: %i[destroy index show] do
    # and we nest this one here rather than under forums -> topics
    # to simplify form URL generation (ie. we can just call
    #   form_for [@comment.commentable, @comment]
    # everywhere
    resources :comments, only: %i[create new update]
  end

  resources :tweets, only: %i[index show], path: 'twitter'

  resources :users do
    resources :emails, id: /[^\/]+/
  end

  # although conditionally inlining admin functionality in the standard
  # resources is elegant it makes page caching difficult because the page
  # looks different for admin users so we provide a separate admin interface
  # for some resources
  namespace :admin do
    resources :forums, only: %i[index show update]
    resources :issues
    resources :posts
    resources :tags
    get 'dashboard' => 'dashboard#show'
  end

  get 'dashboard'       => 'dashboard#show'
  get 'heartbeat/ping'

  # explicit extension here helps nginx send correct Content-Type
  get 'js/:delegated'   => 'js#show',
      :delegated        => %r{([a-z_]+/)+[a-z_]+\.js}

  get 'l/:id'           => 'links#show'
  get 'login'           => 'sessions#new'
  get 'logout'          => 'sessions#destroy'
  get 'misc/:action'    => 'misc'
  get 'search'          => 'search#search'
  get 'support'         => 'support#index'

  root :to => 'posts#index'
end
