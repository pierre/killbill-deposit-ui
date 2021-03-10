require 'test_helper'

class NavigationTest < ActionDispatch::IntegrationTest

  include Deposit::Engine.routes.url_helpers

  test 'can see the main collection page' do
    get '/deposit'
    assert_response :success
  end
end

