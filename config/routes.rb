TimeTracker::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'tasks#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get  'login'  => 'login#index'
  post 'login'  => 'login#login_user'
  get  'logout' => 'login#logout_user'
  get  'forgot_password' => 'login#forgot_password'
  post 'forgot_password' => 'login#deliver_reset_instructions'
  get  'change_password' => 'login#change_password'
  post 'change_password' => 'login#changed_password'

  get  'tasks_history' => 'tasks#history'
  get  'schedule_history' => 'schedule#history'
  get  'schedule_team' => 'schedule#team'

  get  'tasks/pause/:id' => 'tasks#pause'
  get  'tasks/resume/:id' => 'tasks#resume'
  get  'tasks/stop/:id' => 'tasks#stop'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :tasks
  resources :schedule
  resources :users
  resources :departments
  resources :task_actions
  resources :task_customers
  resources :task_details
  resources :task_projects
  resources :task_types

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
