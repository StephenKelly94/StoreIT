Rails.application.routes.draw do

  root to: "static_pages#home"
  get 'about'   => 'static_pages#about'
  get '/folders/:id', to: 'folders#show', as: 'folder'

  #Dropbox routes
  get '/dropbox_authorize' => 'dropbox#authorize', as: 'dropbox_authorize'
  get '/dropbox_deauthorize' => 'dropbox#deauthorize', as: 'dropbox_deauthorize'
  get '/dropbox_callback' => 'dropbox#callback', as: 'dropbox_callback'
  get '/dropbox_download/:parent_id/:id' => 'dropbox#download'
  get '/dropbox_dirty_check/:id' => 'dropbox#dirty_check'
  post '/dropbox_upload' => 'dropbox#upload'
  post '/dropbox_create_folder/:parent_id/:name' => 'dropbox#create_folder'
  delete '/dropbox_delete_item/:parent_id/:id' => 'dropbox#delete_item'

  #Onedrive routes
  get '/onedrive_authorize' => 'onedrive#authorize', as: 'onedrive_authorize'
  get '/onedrive_deauthorize' => 'onedrive#deauthorize', as: 'onedrive_deauthorize'
  get '/onedrive_callback' => 'onedrive#callback', as: 'onedrive_callback'
  get '/onedrive_download/:parent_id/:id' => 'onedrive#download'
  get '/onedrive_dirty_check/:id' => 'onedrive#dirty_check'
  post '/onedrive_upload/' => 'onedrive#upload'
  post '/onedrive_create_folder/:parent_id/:name' => 'onedrive#create_folder'
  delete '/onedrive_delete_item/:parent_id/:id' => 'onedrive#delete_item'

  #Googledrive routes
  get '/googledrive_authorize' => 'googledrive#authorize', as: 'googledrive_authorize'
  get '/googledrive_deauthorize' => 'googledrive#deauthorize', as: 'googledrive_deauthorize'
  get '/googledrive_callback' => 'googledrive#callback', as: 'googledrive_callback'
  get '/googledrive_download/:parent_id/:id' => 'googledrive#download'
  get '/googledrive_dirty_check/:id' => 'googledrive#dirty_check'
  post '/googledrive_upload/' => 'googledrive#upload'
  post '/googledrive_create_folder/:parent_id/:name' => 'googledrive#create_folder'
  delete '/googledrive_delete_item/:parent_id/:id' => 'googledrive#delete_item'

  devise_for :users
  resources :users

  resources :services

  resources :user_files

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
