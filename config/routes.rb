ApiExplorer::Engine.routes.draw do
  root :to => "api#index"

  get :method, :to=>'api#method'
  post :execute, :to=>'api#execute'
end
