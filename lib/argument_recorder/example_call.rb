module ArgumentRecorder
  # ExampleCall represents a specific call to a method, recording the parameter values that were passed
  # to it.
  # @since 0.1.2
  # @attr_reader [Array] arguments normal arguments that were passed to the call
  # @attr_reader [Hash] keyword_arguments keyword arguments that were passed to the call
  class ExampleCall
    attr_reader :arguments, :keyword_arguments

    # @example
    #  ExampleCall.new(method_name: :add, arguments: [1, 2])
    # @example
    #  ExampleCall.new(method_name: :display_icon, keyword_arguments: { kind: :success, message: 'The object was created successfully.' })
    #
    # @param method_name [Symbol]
    # @param arguments [Array]
    # @param keyword_arguments [Hash]
    # @return [ExampleCall]
    def initialize(method_name:, arguments: [], keyword_arguments: [])
      @method_name = method_name
      @arguments = arguments
      @keyword_arguments = keyword_arguments
    end

    # @return [String] of an RDOC example
    def to_rdoc
      [
        "  @example\n    #{@method_name}(",
        [argument_examples, keyword_argument_examples].reject(&:empty?).join(', '),
        ')',
      ].join('')
    end

    private

    # @return [String] of arguments
    def argument_examples
      return '' unless @arguments.any?

      @arguments.map { |value| format_value(value) }.join(', ')
    end

    # @return [String] of keyword arguments
    def keyword_argument_examples
      return '' unless @keyword_arguments.any?

      @keyword_arguments.map { |key, value| "#{key}: #{format_value(value)}" }.join(', ')
    end

    # @param[String,Symbol,Date,TrueClass,FalseClass] any value
    # @return [String] representation of the value as a string
    def format_value(value)
      case value
      when String then "\"#{value}\""
      when Symbol then ":#{value}"
      else
        value.to_s
      end
    end
  end
end
