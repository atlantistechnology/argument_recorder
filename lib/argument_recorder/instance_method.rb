module ArgumentRecorder
  # InstanceMethod represents a specific instance method, including its source location and parameter definitions.
  # There's also room for examples!
  # @since 0.1.2
  class InstanceMethod
    # @example
    #  InstanceMethod.new(method_name: :add, source_location: ['lib/add.rb', 5], parameters: { number1: { position: 0, type: :req }, number2: { position: 1, type: :req }})
    #
    # @param method_name [Symbol]
    # @param source_location [Array<String, Integer>]
    # @param parameters [Hash]
    # @param examples [Array<ExampleCall>]
    # @return [InstanceMethod]
    def initialize(method_name:, source_location:, parameters:, examples: [])
      @method_name = method_name
      @source_location = source_location
      @parameters = parameters
      @examples = examples
    end

    # @return [String] RDOC for the instance method
    def to_rdoc
      [
        "  \e[44m#{@source_location.join(':').ljust(98, ' ')}\e[0m",
        "  \e[44m##{@method_name.to_s.ljust(97, ' ')}\e[0m",
        '',
        examples_as_rdoc,
        '',
        @parameters.map do |parameter_name, parameter_details|
          line_for_param(parameter_name, parameter_details)
        end,
        '',
      ].join("\n")
    end

    private

    # @return [String] RDOC examples
    def examples_as_rdoc
      @examples.map(&:to_rdoc).join("\n")
    end

    # parameter#type can be:
    # :req - required argument
    # :opt - optional argument
    # :rest - rest of arguments as array
    # :keyreq - reguired key argument (2.1+)
    # :key - key argument
    # :keyrest - rest of key arguments as Hash
    # :block - block parameter
    def line_for_param(parameter_name, _parameter_details)
      case @parameters[parameter_name][:type]
      when :req, :opt
        "  @param #{parameter_name} [#{class_from_example_objects(@examples.map { |e| e.arguments[@parameters.keys.index(parameter_name)] }).join(', ')}]"
      when :keyreq, :key
        "  @param #{parameter_name} [#{class_from_example_objects(@examples.map { |e| e.keyword_arguments[parameter_name] }).join(', ')}]"
      else
        "  @param #{parameter_name} [UNKNOWN]"
      end
    end

    # @return [String] Unique list of classes for each of the example objects
    def class_from_example_objects(objects)
      objects.map do |object|
        case object
        when TrueClass, FalseClass then 'Boolean'
        else
          object.class.to_s
        end
      end.uniq
    end
  end
end