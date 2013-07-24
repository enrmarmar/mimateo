MiMateo::Application.routes.draw do
  resources :contacts
  resources :tasks
  resources :messages
  
  root :to => redirect('/index')

  match 'api_index' => 'api#index'
  match 'index' => 'users#index'
  match 'task/:id/:action' => 'tasks#:action'
  match 'contact/:id/:action' => 'contacts#:action'
  match 'task/:id/:action/:contact' => 'tasks#:action'
  match 'notifications/:id/destroy' => 'notifications#destroy'
  match 'task/:id/give/:amount/bones_to/:contact' => 'bones#give'
  match 'google_event/:task_id/:action' => 'google_events#:action'

  match 'login_as_1' => 'users#login_as_1'
  match 'login_as_2' => 'users#login_as_2'
  match 'login_as_3' => 'users#login_as_3'
  match 'login_as_4' => 'users#login_as_4'

  match 'auth/:provider' => 'users#create', :as => 'login'
  match 'auth/:provider/callback' => 'users#create', :as => 'callback'
  match 'auth/failure' => 'users#failure'
  match 'logout' => 'users#destroy'

  match 'check_for_updates/:last_rendered_at' => 'tasks#check_for_updates'

  namespace :api do
    namespace :v1 do
      match 'tasks' => 'tasks#tasks'
      match 'task/:action' => 'tasks#:action'
    end
  end
end
