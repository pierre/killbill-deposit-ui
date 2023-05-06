# frozen_string_literal: true

require 'deposit/client'

module Deposit
  class CollectionController < EngineController
    def index
      @account_id = params[:account_id]
      @currency = params[:currency] || 'USD'
    end

    def record_payments
      cached_options_for_klient = options_for_klient

      payments = {}
      params.each do |k, amount|
        next unless k.start_with?('payment_amount_')

        _, invoice_nb = k.split('payment_amount_')
        payments[invoice_nb] = amount
      end

      begin
        Killbill::Deposit::DepositClient.record_payments(params[:account_id],
                                                         params[:effective_date],
                                                         params[:payment_reference_number],
                                                         params[:deposit_type],
                                                         payments,
                                                         cached_options_for_klient[:username],
                                                         params[:reason],
                                                         params[:comment],
                                                         cached_options_for_klient)

        flash[:notice] = 'Deposit successfully collected'
        redirect_to kaui_engine.account_path(params[:account_id])
      rescue StandardError => e
        flash.now[:error] = case e
                            when ::KillBillClient::API::NotFound
                              'Unable to record payment: invoice not found'
                            when ::KillBillClient::API::BadRequest
                              'Unable to record payment: deposit type, reference date, and reference number must be specified'
                            when ::KillBillClient::API::UnprocessableEntity
                              'Unable to record payment: amount too small or payment in UNKNOWN state'
                            else
                              "Internal error: #{as_string(e)}"
                            end

        @account_id = params[:account_id]
        @currency = params[:currency] || 'USD'

        render :index
      end
    end

    def account_invoices
      cached_options_for_klient = options_for_klient

      searcher = lambda do |search_key, _offset, _limit|
        account = begin
          KillBillClient::Model::Account.find_by_id(search_key, false, false,
                                                    cached_options_for_klient)
        rescue StandardError
          nil
        end
        if account.nil?
          []
        else
          account.invoices(cached_options_for_klient)
        end
      end

      data_extractor = lambda do |invoice, column|
        [
          invoice.invoice_number.to_i,
          invoice.invoice_date,
          invoice.amount,
          invoice.balance,
          nil
        ][column]
      end

      formatter = lambda do |invoice|
        [
          invoice.invoice_number,
          invoice.invoice_date,
          view_context.humanized_money_with_symbol(Money.from_amount(invoice.amount.to_f, invoice.currency)),
          view_context.humanized_money_with_symbol(Money.from_amount(invoice.balance.to_f, invoice.currency)),
          nil
        ]
      end

      begin
        search_key = (params[:search] || {})[:value].presence
        offset = (params[:start] || 0).to_i
        limit = (params[:length] || 50).to_i
        pages = searcher.call(search_key, offset, limit)
      rescue StandardError => e
        error = e.to_s
      end

      json = {
        draw: (params[:draw] || 0).to_i,
        # We need to fill-in a number to make DataTables happy
        recordsTotal: pages.nil? ? 0 : limit,
        recordsFiltered: pages.nil? ? 0 : limit,
        data: []
      }
      json[:error] = error unless error.nil?

      pages ||= []

      # Until we support server-side sorting
      ordering = ((params[:order] || {})[:'0'] || {})
      ordering_column = (ordering[:column] || 0).to_i
      ordering_dir = ordering[:dir] || 'asc'
      unless search_key.nil?
        pages.sort! do |a, b|
          a = data_extractor.call(a, ordering_column)
          b = data_extractor.call(b, ordering_column)
          sort = a <=> b
          sort.nil? ? -1 : sort
        end
      end
      pages.reverse! if (ordering_dir == 'desc' && limit >= 0) || (ordering_dir == 'asc' && limit.negative?)

      pages.each { |page| json[:data] << formatter.call(page) }

      respond_to do |format|
        format.json { render json: json }
      end
    end

    private

    def options_for_klient
      user = current_tenant_user
      {
        username: user[:username],
        password: user[:password],
        session_id: user[:session_id],
        api_key: user[:api_key],
        api_secret: user[:api_secret],
        # Pass the X-Request-Id seen by Rails to Kill Bill
        # Note that this means that subsequent requests issued by a single action will share the same X-Request-Id in Kill Bill
        request_id: request.request_id
      }
    end
  end
end
