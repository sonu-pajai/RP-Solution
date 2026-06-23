Rails.application.routes.draw do
  devise_for :users
  root "dashboard#index"
  resources :reporting_entities
  resources :relationships
  resources :transactions
  resources :periods
  get "rp_list", to: "rp_list#index"
  get "rp_master", to: "rp_master#index"
  get "rp_master/new", to: "rp_master#new", as: :new_rp_master
  post "rp_master", to: "rp_master#create", as: :rp_master_create
  get "rp_master/bulk_upload", to: "rp_master#bulk_upload", as: :rp_master_bulk_upload
  post "rp_master/bulk_upload", to: "rp_master#bulk_upload"
  get "rp_master/template", to: "rp_master#template", as: :rp_master_template
  get "rp_master/export", to: "rp_master#export", as: :rp_master_export
  get "rp_master/:id/edit", to: "rp_master#edit", as: :edit_rp_master
  get "rp_master/:id", to: "rp_master#show", as: :show_rp_master
  patch "rp_master/:id", to: "rp_master#update", as: :update_rp_master
  delete "rp_master/:id", to: "rp_master#destroy", as: :destroy_rp_master
  get "rp_list_consolidation", to: "rp_list_consolidation#index", as: :rp_list_consolidation
  post "rp_list_consolidation", to: "rp_list_consolidation#consolidate", as: :rp_list_consolidation_submit
  get "rp_list_consolidation/export", to: "rp_list_consolidation#export", as: :rp_list_consolidation_export
  get "rp_list_consolidation/bulk_upload", to: "rp_list_consolidation#bulk_upload", as: :rp_list_consolidation_bulk_upload
  post "rp_list_consolidation/bulk_upload", to: "rp_list_consolidation#bulk_upload"
  get "rp_list_consolidation/template", to: "rp_list_consolidation#template", as: :rp_list_consolidation_template
  get "rp_list_consolidation/:id/edit", to: "rp_list_consolidation#edit", as: :edit_rp_consolidation
  patch "rp_list_consolidation/:id", to: "rp_list_consolidation#update", as: :update_rp_consolidation
  delete "rp_list_consolidation/:id", to: "rp_list_consolidation#destroy", as: :destroy_rp_consolidation
  get "rp_consolidation_output", to: "rp_consolidation_output#index", as: :rp_consolidation_output
  get "rp_transactions", to: "rp_transactions#index", as: :rp_transactions
  get "rp_transactions/new", to: "rp_transactions#new", as: :new_rp_transaction
  post "rp_transactions", to: "rp_transactions#create"
  get "rp_transactions/bulk_upload", to: "rp_transactions#bulk_upload", as: :bulk_upload_rp_transactions
  post "rp_transactions/bulk_upload", to: "rp_transactions#bulk_upload"
  get "rp_transactions/sample", to: "rp_transactions#sample", as: :sample_rp_transactions
  get "rp_transactions/export", to: "rp_transactions#export", as: :export_rp_transactions
  get "rp_transactions/reporting_units", to: "rp_transactions#reporting_units"
  get "rp_transactions/sub_natures", to: "rp_transactions#sub_natures"
  get "rp_transactions/transaction_types", to: "rp_transactions#transaction_types"
  get "rp_transactions/:id", to: "rp_transactions#show", as: :rp_transaction
  get "rp_transactions/:id/edit", to: "rp_transactions#edit", as: :edit_rp_transaction
  patch "rp_transactions/:id", to: "rp_transactions#update"
  delete "rp_transactions/:id", to: "rp_transactions#destroy"
end
