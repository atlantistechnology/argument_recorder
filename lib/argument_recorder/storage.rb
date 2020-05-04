require 'argument_recorder/example_call'

module ArgumentRecorder
  class Storage
    attr_reader :recordings

    # @return [Storage]
    def initialize
      @recordings = {}
    end

    # @yield [class_name, data] class_name is a String, data is a Hash
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
    # 
    # @param [Symbol] method Initialize the method in storage by recording the method name, source, and param details
    # @return [NilClass]
    def initialize_method(method)
      target_class = method.owner
      method_name = method.original_name

      # puts " \e[42m\e[30mIntializing #{target_class}##{method_name} with #{target_class.instance_method(method_name).parameters.length} parameters\e[0m\e[0m"

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
      nil
    end

    # @param [String] class_name
    # @param [Symbol] method_name
    # @param [Array] arguments
    # @param [Hash] keyword_arguments
    def record_example(class_name:, method_name:, arguments:, keyword_arguments:)
      @recordings[class_name][method_name][:examples].push(
        ExampleCall.new(method_name: method_name, arguments: arguments, keyword_arguments: keyword_arguments),
      )
    rescue => error
      puts "[ArgumentRecorder::Storage#record_example] #{error}"
    end
  end
end
