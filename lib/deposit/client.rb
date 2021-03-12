module Killbill
  module Deposit

    class DepositClient < KillBillClient::Model::Resource

      KILLBILL_DEPOSIT_PREFIX = '/plugins/killbill-deposit'

      class << self

        def record_payment(account_id, effective_date, payment_reference_number, deposit_type, payments)
        end

        def deposit_plugin_available?(options = nil)
          path = KILLBILL_DEPOSIT_PREFIX
          KillBillClient::API.get path, nil, options

          return true, nil
          # Response error if the deposit plugin is not listening
        rescue KillBillClient::API::ResponseError => e
          return false, e.message.to_s
        end

      end

    end

  end
end
