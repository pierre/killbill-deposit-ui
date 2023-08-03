# frozen_string_literal: true

require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest
  include Deposit::Engine.routes.url_helpers

  test 'can see the main collection page' do
    get '/deposit'
    assert_response :success
  end

  test 'test_payment_amount_field_behavior' do
    # Create mock invoices and mock payments
    mock_invoices = [Invoice.new(balance: 0), Invoice.new(balance: 10)]
    mock_payments = [Payment.new(amount: 0), Payment.new(amount: 10)]

    # Simulate a GET request to the deposit page
    get '/deposit'

    # Check the response for the expected behavior of the payment amount input field
    assert_select 'input.payment_amount_invoice', count: 2
    assert_select 'input.payment_amount_invoice[disabled]', count: 1
    assert_select 'input.payment_amount_invoice:not([disabled])', count: 1
    assert_select 'input.payment_amount_invoice[value="0"]', count: 2
  end
end
