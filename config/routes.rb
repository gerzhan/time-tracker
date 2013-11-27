TimeTracker::Application.routes.draw do
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'
  get  'login'  => 'login#index'
  post 'login'  => 'login#login_user'
  get  'logout' => 'login#logout_user'
  get  'forgot_password' => 'login#forgot_password'
  post 'forgot_password' => 'login#deliver_reset_instructions'
  get  'change_password' => 'login#change_password'
  post 'change_password' => 'login#changed_password'
  
  get  'profile' => 'profile#index'
  put  'profile' => 'profile#update_password'
  post 'profile' => 'profile#update_profile'

  get  'reports/user_tasks' => 'reports#user_task_report'
  get  'reports/department_tasks' => 'reports#department_task_report'
  get  'reports/user_schedule' => 'reports#user_schedule_report'
  get  'reports/department_schedule' => 'reports#department_schedule_report'

  get    'scheduled_tasks/new' => 'tasks#scheduled_new', :as => :new_scheduled_task
  post   'scheduled_tasks' => 'tasks#scheduled_create', :as => :scheduled_tasks
  get    'scheduled_tasks/:id' => 'tasks#scheduled_show', :as => :scheduled_task
  get    'scheduled_tasks/:id/edit' => 'tasks#scheduled_edit', :as => :edit_scheduled_task
  put    'scheduled_tasks/:id' => 'tasks#scheduled_update'
  delete 'scheduled_tasks/:id' => 'tasks#scheduled_destroy'

  get  'tasks/history' => 'tasks#history'

  get  'schedule/history' => 'schedule#history'
  get  'schedule/team' => 'schedule#team'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  resources :tasks do
    member do
      get 'pause'
      get 'resume'
      get 'stop'
      get 'duplicate'
    end

    resources :task_slots
  end
  
  resources :schedule do
    member do
      get  'approve'
      get  'reject'
      post 'confirm_reject'
    end
  end

  resources :users
  resources :departments do
    resources :time_request_approvers
  end
  
  resources :task_types
  resources :task_customers
  resources :task_projects do
    resources :task_actions do
      resources :task_details
    end
  end

  resources :time_request_types

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
