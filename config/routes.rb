Deposit::Engine.routes.draw do

  root to: 'collection#index'

  resources :collection, :only => [:index]

  scope '/collection' do
  end

end
