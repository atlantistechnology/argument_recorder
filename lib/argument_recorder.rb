require 'argument_recorder/version'
require 'pry'

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
        # binding.pry

        # Copy the original method
        alias_method "original_#{method_name}".to_sym, method_name

        # Remove the original method
        remove_method method_name

        # Redifine the method
        define_method(method_name) do |*arguments|
          # Record data about the arguments
          self.class.instance_variable_get(:@argument_recordings)[method_name].tap do |method_storage|
            arguments.each_with_index do |argument_value, argument_index|
              if argument_value.is_a?(Hash)
                argument_value.each do |key, value|
                  method_storage[key][:examples].push(value)
                end
              else
                method_storage[method_storage.keys[argument_index]][:examples].push argument_value
              end
            end
          end

          # Call the original method
          send("original_#{method_name}".to_sym, *arguments)
        end
      end
    end

    def relevant_methods_names
      (instance_methods - Object.methods).select do |method_name|
        instance_method(method_name).arity.positive?
      end
    end
  end
end
