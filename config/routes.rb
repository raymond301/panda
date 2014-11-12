Panda::Application.routes.draw do
  #resources :pathways
  get "pathways" => 'pathways#index'
  get "pathways/new" => 'pathways#new', :as => 'new'
  post "pathways/create" => 'pathways#create', :as => 'create'
  get "pathways/edit" => 'pathways#edit', :as => 'edit'
  post "pathways/update" => 'pathways#update', :as => 'update'
  delete "pathways/destroy" => 'pathways#destroy', :as => 'destroy'
  get "pathways/cytoscape_help" => 'pathways#cytoscape_help'

  resources :annotation_collections
  post "/from_file" => 'annotation_collections#new_w_file'

  resources :groups

  devise_for :users

  get "user/autocomplete_user_username" => 'dashboard#autocomplete_user_username', :as => "autocomplete_user_username_users"

  get "dashboard/index"
  post "dashboard/index"  ### Search & Filter Capability
  get "dashboard/pathway_map"
  post "dashboard/create_enrichment"
  delete "dashboard/destroy_enrichment"
  get "dashboard/options"
  get "dashboard/adminView"
  get "dashboard/su"
  get "dashboard/make_preset"
  get "dashboard/download_tmp"
  post "dashboard/create_icon"
  delete "dashboard/destroy_tmp"
  post "dashboard/select_this_group"

  get "dashboard/list_custom_icons"
  delete "dashboard/destroy_custom_icon"



  # resources :users do
##   get :autocomplete_user_username, :on => :collection
 # end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'dashboard#index'

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
