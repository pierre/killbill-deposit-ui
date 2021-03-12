Deposit::Engine.routes.draw do

  root to: 'collection#index'

  resources :collection, :only => [:index]

  scope '/collection' do
    match '/record' => 'collection#record_payment', :via => :post, :as => 'do_record_payment'
    match '/account_invoices' => 'collection#account_invoices', :via => :get, :as => 'account_invoices'
  end

end
