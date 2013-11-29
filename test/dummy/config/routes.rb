Rails.application.routes.draw do

  mount ApiExplorer::Engine => "/api_explorer"

  get '/v1/users' => 'users#index'
end
