# frozen_string_literal: true

Deposit::Engine.routes.draw do
  root to: 'collection#index'

  resources :collection, only: [:index]

  scope '/collection' do
    match '/record' => 'collection#record_payments', :via => :post, :as => 'do_record_payments'
    match '/account_invoices' => 'collection#account_invoices', :via => :get, :as => 'account_invoices'
  end
end
