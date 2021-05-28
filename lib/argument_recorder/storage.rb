require 'argument_recorder/example_call'

module ArgumentRecorder
  class Storage
    attr_reader :examples

    # @return [Storage]
    def initialize
      @methods = {}  # A Hash containing `UnboundMethod` => `Hash`
      @examples = {} # Examples of calls to various methods
    end

    # @yield [method, data] method is an `UnboundMethod`, data is a `Hash`
    def each_method
      @methods.each do |method, data|
        yield method, data
      end
    end

    # A unique list of locations where this method was called
    #
    # @example
    #   ['/var/projects/argument_recorder/spec/inherited_class_spec.rb:17']
    #
    # @param [UnboundMethod] method
    #
    # @return [Array]
    def lines_where_method_was_called(method)
      examples[method].map do |example_method|
        "* #{example_method.calling_line&.split(':')&.take(2)&.join(':')}"
      end.uniq
    end

    # parameter#type can be:
    # :req - required argument
    # :opt - optional argument
    # :rest - rest of arguments as array
    # :keyreq - reguired key argument (2.1+)
    # :key - key argument
    # :keyrest - rest of key arguments as Hash
    # :block - block parameter

    # @param [UnboundMethod] method Initialize the method in storage by adding it to @methods registry and initializing a space in @examples
    # @return [NilClass]
    def initialize_method(method)
      # puts " \e[42m\e[30mIntializing ##{method_name} with #{method.parameters.length} parameters\e[0m\e[0m"
      return if @methods.key?(method)

      method_name = method.original_name
      original_method = method.owner.instance_method("__argument_recorder_#{method_name}".to_sym)

      # Cache this UnboundMethod and some useful data about it
      @methods[method] ||= {
        name: method_name,
        original_source_location: original_method.source_location,
        parameters: {},
      }

      # Add parameter details to the useful data associated with this UnboundMethod
      original_method.parameters.each_with_index do |(type, parameter_name), index|
        @methods[method][:parameters][parameter_name] = {
          position: index,
          type: type,
        }
      end

      # Initialize an empty array of examples of calls to this method
      @examples[method] ||= []

      nil
    end

    # @param [String] class_name
    # @param [Symbol] method_name
    # @param [Array] arguments
    # @param [Hash] keyword_arguments
    def record_example(class_name:, method_name:, arguments:, keyword_arguments:, calling_line:)
      method = Module.const_get(class_name).instance_method(method_name)
      initialize_method(method)

      @examples[method].push(
        ExampleCall.new(
          method_name: method_name,
          arguments: arguments,
          keyword_arguments: keyword_arguments,
          calling_line: calling_line,
        ),
      )
    end
  end
end
