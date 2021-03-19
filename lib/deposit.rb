# frozen_string_literal: true

require 'deposit/engine'

module Deposit
  mattr_accessor :current_tenant_user
  mattr_accessor :layout

  mattr_accessor :deposit_types

  self.current_tenant_user = lambda { |_session, _user|
    { username: 'admin',
      password: 'password',
      session_id: nil,
      api_key: KillBillClient.api_key,
      api_secret: KillBillClient.api_secret }
  }

  def self.config
    {
      layout: layout || 'deposit/layouts/deposit_application'
    }
  end

  # Default deposit types
  self.deposit_types = %w[Wire
                          Check
                          Cash
                          OTHER]
end
