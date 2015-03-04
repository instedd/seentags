Rails.application.routes.draw do
  root to: 'home#index'

  post '/login' => 'home#login'
  get '/logoff' => 'home#logoff'
  get '/home' => 'home#home'

  post '/create_account' => 'home#create_account'
  get '/account/edit' => 'home#edit_account'
  post '/account/update' => 'home#update_account'

  match '/in/:key' => 'report_set#incoming', via: [:get, :post]

  get '/report_set/new' => 'report_set#new'
  post '/report_set/create' => 'report_set#create'
  get '/report_set/:id' => 'report_set#view'

  post '/report_set/:report_set_id/create_report' => 'report#create'
  match '/report_set/:id/:action', :controller => 'report_set', via: [:get, :post, :put, :delete]

  match '/report/:id/:action', :controller => 'report', via: [:get, :post, :put, :delete]

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

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
