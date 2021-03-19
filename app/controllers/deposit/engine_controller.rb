# frozen_string_literal: true

module Deposit
  class EngineController < ApplicationController
    layout :get_layout

    # Used to format flash error messages
    def as_string(e)
      if e.is_a?(KillBillClient::API::ResponseError)
        "Error #{e.response.code}: #{as_string_from_response(e.response.body)}"
      else
        log_rescue_error(e)
        e.message
      end
    end

    def log_rescue_error(error)
      Rails.logger.warn "#{error.class} #{error.to_s}. #{error.backtrace.join("\n")}"
    end

    def get_layout
      layout ||= Deposit.config[:layout]
    end

    def current_tenant_user
      # If the rails application on which that engine is mounted defines such method (Devise), we extract the current user,
      # if not we default to nil, and serve our static mock configuration
      user = current_user if respond_to?(:current_user)
      Deposit.current_tenant_user.call(session, user)
    end
  end
end
