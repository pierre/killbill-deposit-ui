# frozen_string_literal: true

module Killbill
  module Deposit
    class DepositClient < KillBillClient::Model::Resource
      KILLBILL_DEPOSIT_PREFIX = '/plugins/killbill-deposit'

      class << self
        def record_payments(account_id, effective_date, payment_reference_number, deposit_type, invoice_payments, user = nil, reason = nil, comment = nil, options = {})
          payments = []
          invoice_payments.each do |invoice_number, payment_amount|
            payments << { invoiceNumber: invoice_number, paymentAmount: payment_amount }
          end

          body = {
            accountId: account_id,
            effectiveDate: effective_date,
            paymentReferenceNumber: payment_reference_number,
            depositType: deposit_type,
            payments: payments
          }.to_json

          path = "#{KILLBILL_DEPOSIT_PREFIX}/record"
          response = KillBillClient::API.post path,
                                              body,
                                              {},
                                              {
                                                user: user,
                                                reason: reason,
                                                comment: comment
                                              }.merge(options)
          response.body
        end

        def deposit_plugin_available?(options = nil)
          path = KILLBILL_DEPOSIT_PREFIX + '/healthcheck'
          KillBillClient::API.get path, nil, options

          [true, nil]
          # Response error if the deposit plugin is not listening
        rescue KillBillClient::API::ResponseError => e
          [false, e.message.to_s]
        end
      end
    end
  end
end
