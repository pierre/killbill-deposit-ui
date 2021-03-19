# frozen_string_literal: true

require 'test_helper'

class DepositTest < ActiveSupport::TestCase
  test 'can load Deposit module' do
    assert_kind_of Module, Deposit
  end
end
