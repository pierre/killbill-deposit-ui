require 'deposit/client'

module Deposit
  class CollectionController < EngineController

    def index
    end

    private

    def options_for_klient
      user = current_tenant_user
      {
          :username => user[:username],
          :password => user[:password],
          :session_id => user[:session_id],
          :api_key => user[:api_key],
          :api_secret => user[:api_secret]
      }
    end
  end
end
