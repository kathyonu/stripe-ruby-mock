module StripeMock
  module RequestHandlers
    module Accounts

      def Accounts.included(klass)
        klass.add_handler 'post /v1/accounts',      :new_account
        klass.add_handler 'get /v1/account',        :get_account
        klass.add_handler 'get /v1/accounts/(.*)',  :get_account
        klass.add_handler 'post /v1/accounts/(.*)', :update_account
        klass.add_handler 'get /v1/accounts',       :list_accounts
      end

      def new_account(route, method_url, params, headers)
        params[:id] ||= new_id('acct')
        route =~ method_url
        accounts[ params[:id] ] ||= Data.mock_account(params)
      end

      def get_account(route, method_url, params, headers)
        route =~ method_url
        Data.mock_account
        # the below replaces the above
        # assert_existence :account, $1, accounts[$1]
        # 'Allow accounts to be created and then fetched by id'
        # https://github.com/johanoskarsson/stripe-ruby-mock/commit/cc26fe2219a54eda2301bf6be7720179f05b5605
        # TODO: test it
      end

      def update_account(route, method_url, params, headers)
        route =~ method_url
        assert_existence :account, $1, accounts[$1]
        accounts[$1].merge!(params)
      end

      def list_accounts(route, method_url, params, headers)
        Data.mock_list_object(accounts.values, params)
      end
    end
  end
end
