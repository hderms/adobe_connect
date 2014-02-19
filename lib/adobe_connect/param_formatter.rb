module AdobeConnect

  # Public: Responsible for translating params hashes into query strings 
  class ParamFormatter
    attr_reader :params

    # Public: Create a new AdobeConnect::ParamFormatter.
    #
    # params - A hash of params to format.
    def initialize(params)
      @params = params
    end

    # Public: Translate a hash of params into a query string. Dasherize any
    # underscored values, and escape URL unfriendly values.
    #
    # Returns a query string.
    def format
      Hash[params.map {|k, v| [k.to_s.dasherize, v]}]
    end
  end
end
