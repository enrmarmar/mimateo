Prueba1::Application.routes.draw do
  resources :contacts
  resources :tasks
  resources :messages
  
  root :to => redirect('/index')

  match 'api_index' => 'api#index'
  match 'index' => 'sessions#index'
  match 'task/:id/:action' => 'tasks#:action'
  match 'contact/:id/:action' => 'contacts#:action'
  match 'task/:id/:action/:contact' => 'tasks#:action'
  match 'notifications/:id/destroy' => 'notifications#destroy'
  match 'task/:id/give/:amount/bones_to/:contact' => 'bones#give'

  match 'login_as_1' => 'sessions#login_as_1'
  match 'login_as_2' => 'sessions#login_as_2'
  match 'login_as_3' => 'sessions#login_as_3'
  match 'login_as_4' => 'sessions#login_as_4'

  match 'auth/:provider' => 'sessions#create',:as => 'login'
  match 'auth/:provider/callback' => 'sessions#create'
  match '/auth/failure', :to => 'sessions#failure'
  match 'logout' => 'sessions#destroy'

  namespace :api do
    namespace :v1 do
      match 'index' => 'tasks#index'
    end
  end
end
