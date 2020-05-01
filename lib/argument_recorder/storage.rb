require 'argument_recorder/example_call'

module ArgumentRecorder
  class Storage
    attr_reader :recordings

    def initialize
      @recordings = {}
    end

    def each_class
      @recordings.each do |class_name, data|
        yield class_name, data
      end
    end

    # parameter#type can be:
    # :req - required argument
    # :opt - optional argument
    # :rest - rest of arguments as array
    # :keyreq - reguired key argument (2.1+)
    # :key - key argument
    # :keyrest - rest of key arguments as Hash
    # :block - block parameter
    def initialize_method(method)
      target_class = method.owner
      method_name = method.original_name

      puts " \e[42m\e[30mIntializing #{target_class}##{method_name} with #{target_class.instance_method(method_name).parameters.length} parameters\e[0m\e[0m"

      @recordings[target_class.to_s] ||= {}
      @recordings[target_class.to_s][method_name] ||= {
        source_location: target_class.instance_method(method_name).source_location,
        parameters: {},
        examples: [],
      }

      target_class.instance_method(method_name).parameters.each_with_index do |(type, parameter_name), index|
        @recordings[target_class.to_s][method_name][:parameters][parameter_name] = {
          position: index,
          type: type,
        }
      end
    end

    def record_example(class_name:, method_name:, arguments:, keyword_arguments:)
      @recordings[class_name][method_name][:examples].push(
        ExampleCall.new(method_name: method_name, arguments: arguments, keyword_arguments: keyword_arguments),
      )
    end
  end
end
