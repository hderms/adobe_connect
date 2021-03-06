module AdobeConnect

  # Public: Manages calls to the Connect API.
  class Service
    attr_reader :username, :domain, :session

    # Public: Create a new AdobeConnect::Service.
    #
    # options - An AdobeConnect::Config object or a hash with the keys:
    #           :username - An Adobe Connect username.
    #           :password - The Connect user's password.
    #           :domain   - The domain for the Connect instance (with protocol
    #                       prepended).
    def initialize(options = AdobeConnect::Config)
      @username      = options[:username]
      @password      = options[:password]
      @domain        = options[:domain]
      @authenticated = false
    end

    # Public: Authenticate against the currently configured Connect service.
    #
    # Returns a boolean.
    def log_in(opts={})
      response = request('login', { :login => username, :password => password }, false)
      if response.at_xpath('//status').attr('code') == 'ok'
        unless opts[:no_session]
          session_regex  = /BREEZESESSION=([^;]+)/
          @session       = response.fetch('set-cookie').match(session_regex)[1]
          @authenticated = true
        else
          true
        end
      else
        false
      end
    end

    # Public: Get the current authentication status.
    #
    # Returns a boolean.
    def authenticated?
      @authenticated
    end

    # Public: Forward any missing methods to the Connect instance.
    #
    # method - The name of the method called.
    # *args  - An array of arguments passed to the method.
    #
    # Examples
    #
    #   service = AdobeConnect::Service.new
    #   service.sco_by_url(url_path: '/example/') #=> calls service.request.
    #
    # Returns an AdobeConnect::Response.
    def method_missing(method, *args)
      action = method.to_s.dasherize
      params = args.first

      request(action, params)
    end

    private
    attr_reader :password

    # Public: Execute a call against the Adobe Connect instance.
    #
    # action      - The name of the API action to call.
    # params      - A hash of params to pass in the request.
    # use_session - If true, require an active session (default: true).
    #
    # Returns an AdobeConnect::Response.
    def request(action, params={}, use_session = true)
      params ||={}
      if use_session
        log_in unless authenticated?
        params[:session] = session
      end

      params[:action] = action

      #coerce this into a form HTTParty expects
      params = {query: ParamFormatter.new(params).format}
      puts params
      response     = HTTParty.get("#{domain}/api/xml", params)
      AdobeConnect::Response.new(response)
    end
  end
end
