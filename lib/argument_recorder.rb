require 'argument_recorder/version'

module ArgumentRecorder
  class Error < StandardError; end
  # Your code goes here...

  def self.included(parent_class)
    parent_class.extend(ClassMethods)
  end

  module ClassMethods
    def record_arguments
      @argument_recordings = {}

      relevant_methods_names.each do |method_name| # symbol
        @argument_recordings[method_name] = {}

        # type can be:
        # :req - required argument
        # :opt - optional argument
        # :rest - rest of arguments as array
        # :keyreq - reguired key argument (2.1+)
        # :key - key argument
        # :keyrest - rest of key arguments as Hash
        # :block - block parameter
        instance_method(method_name).parameters.each do |type, parameter_name|
          @argument_recordings[method_name][parameter_name] = {
            type: type,
            examples: [],
          }
        end

        # Copy the original method
        alias_method "original_#{method_name}".to_sym, method_name

        # Remove the original method
        remove_method method_name

        # Redifine the method
        create_wrapper_method(method_name)
      end
    end

    def create_wrapper_method(method_name)
      method_storage = instance_variable_get(:@argument_recordings)[method_name]

      define_method(method_name) do |*arguments, **keyword_arguments, &block|
        # Record data about the arguments
        arguments.each_with_index do |argument_value, argument_index|
          method_storage[method_storage.keys[argument_index]][:examples].push argument_value
        end

        # Record data about the keyword arguments
        keyword_arguments.each do |key, value|
          method_storage[key][:examples].push(value)
        end

        # Call the original method
        if RUBY_VERSION > '2.7.0'
          send("original_#{method_name}".to_sym, *arguments, **keyword_arguments)
        else
          if keyword_arguments.any?
            send("original_#{method_name}".to_sym, **keyword_arguments)
          else
            send("original_#{method_name}".to_sym, *arguments)
          end
        end
      end
    end

    def relevant_methods_names
      (instance_methods - Object.methods).select do |method_name|
        next if instance_method(method_name).arity.zero?

        next unless instance_method(method_name).owner == self

        true
      end
    end

    def display_argument_data
      puts "\e[32m#{relevant_methods_names.length} Relevant methods found.\e[0m"
      instance_variable_get(:@argument_recordings).each do |(method_name, argument_data)|
        puts "   \e[44m:#{method_name}\e[0m"
        argument_data.each do |(parameter_name, parameter_data)|
          puts "     Parameter Name: #{parameter_name}"
          puts "       Type: #{parameter_data[:type]}"
          puts "       Examples: #{parameter_data[:examples]}"
        end
      end
    end
  end
end
