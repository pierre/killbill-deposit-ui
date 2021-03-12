require 'deposit/client'

module Deposit
  class CollectionController < EngineController

    def index
      @account_id = params[:account_id]
      @currency = params[:currency] || 'USD'
    end

    def record_payment
      payments = {}
      params.each do |k, amount|
        next unless k.start_with?('payment_amount_')
        _, invoice_nb = k.split('payment_amount_')
        payments[invoice_nb] = amount
      end

      Killbill::Deposit::DepositClient.record_payment(params[:account_id], params[:effective_date], params[:payment_reference_number], params[:deposit_type], payments)

      flash[:notice] = 'Deposit successfully collected'
      redirect_to kaui_engine.account_path(params[:account_id])
    end

    def account_invoices
      cached_options_for_klient = options_for_klient

      searcher = lambda do |search_key, offset, limit|
        account = KillBillClient::Model::Account.find_by_id(search_key, false, false, cached_options_for_klient) rescue nil
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
      rescue => e
        error = e.to_s
      end

      json = {
        :draw => (params[:draw] || 0).to_i,
        # We need to fill-in a number to make DataTables happy
        :recordsTotal => pages.nil? ? 0 : limit,
        :recordsFiltered => pages.nil? ? 0 : limit,
        :data => []
      }
      json[:error] = error unless error.nil?

      pages ||= []

      # Until we support server-side sorting
      ordering = ((params[:order] || {})[:'0'] || {})
      ordering_column = (ordering[:column] || 0).to_i
      ordering_dir = ordering[:dir] || 'asc'
      pages.sort! do |a, b|
        a = data_extractor.call(a, ordering_column)
        b = data_extractor.call(b, ordering_column)
        sort = a <=> b
        sort.nil? ? -1 : sort
      end unless search_key.nil? # Keep DB ordering when listing all entries
      pages.reverse! if ordering_dir == 'desc' && limit >= 0 || ordering_dir == 'asc' && limit < 0

      pages.each { |page| json[:data] << formatter.call(page) }

      respond_to do |format|
        format.json { render :json => json }
      end
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
