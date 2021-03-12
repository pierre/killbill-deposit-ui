require 'deposit/engine'

module Deposit

  mattr_accessor :current_tenant_user
  mattr_accessor :layout

  mattr_accessor :deposit_types

  self.current_tenant_user = lambda { |session, user|
    {:username => 'admin',
     :password => 'password',
     :session_id => nil,
     :api_key => KillBillClient.api_key,
     :api_secret => KillBillClient.api_secret}
  }

  def self.config(&block)
    {
        :layout => layout || 'deposit/layouts/deposit_application',
    }
  end

  # Default deposit types
  self.deposit_types = ['Wire',
                        'Check',
                        'Cash',
                        'OTHER']
end
