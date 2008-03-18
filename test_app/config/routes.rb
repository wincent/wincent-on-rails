ActionController::Routing::Routes.draw do |map|
  map.resources :twitters
  map.root :controller => 'twitters'
end
