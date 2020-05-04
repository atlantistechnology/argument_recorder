require 'argument_recorder/version'
require 'argument_recorder/storage'
require 'argument_recorder/instance_method'

require 'awesome_print'
require 'pry'

# Main entrypoint.
# @since 0.1.1
#
# @example
#   class SampleClass
#     include ArgumentRecorder
#
#     def sample_method
#     end
#
#     record_arguments
#   end
#
module ArgumentRecorder
  class Error < StandardError; end

  # Initialize storage and inject functionality
  # @param [Class] parent_class
  # @return [NilClass]
  def self.included(parent_class)
    ArgumentRecorder::STORAGE ||= Storage.new
    parent_class.extend(ClassMethods)
    nil
  end

  # puts formatted contents of ArgumentRecorder::STORAGE
  # @return [NilClass]
  def self.display_argument_data
    # ap ArgumentRecorder::STORAGE.recordings
    # puts "\n\n"

    ArgumentRecorder::STORAGE.each_class do |class_name, data|
      puts "\e[44m#{class_name.ljust(100, ' ')}\e[0m"
      data.each do |method_name, method_details|
        instance_method = InstanceMethod.new(
          method_name: method_name,
          source_location: method_details[:source_location],
          parameters: method_details[:parameters],
          examples: method_details[:examples],
        )
        puts instance_method.to_rdoc
        puts "\n\n"
      end
      nil
    end
  end

  # Namespace for methods added to target classes whose methods we want to record
  # @since 0.1.1
  module ClassMethods

    # Initialize recording for each relevant method by
    #  1. Notifying Storage of the method
    #  2. Alias the original method to the "original_" namespace
    #  3. Remove the original method
    #  4. Create the wrapper method
    # @return [NilClass]
    def record_arguments
      relevant_methods_names.each do |method_name| # symbol
        ArgumentRecorder::STORAGE.initialize_method(instance_method(method_name))

        # Copy the original method
        alias_method("__argument_recorder_#{method_name}".to_sym, method_name)

        # Remove the original method
        remove_method(method_name)

        # Redifine the method
        create_wrapper_method(method_name)
      end
      nil
    end

    # Create a wrapper method which records example calls and then send the arguments on
    # to the original method
    # @return [NilClass]
    def create_wrapper_method(method_name)
      define_method(method_name) do |*arguments, **keyword_arguments|
        ArgumentRecorder::STORAGE.record_example(
          class_name: self.class.to_s,
          method_name: method_name,
          arguments: arguments,
          keyword_arguments: keyword_arguments,
        )

        # Call the original method
        if keyword_arguments.any?
          send("__argument_recorder_#{method_name}".to_sym, **keyword_arguments)
        else
          send("__argument_recorder_#{method_name}".to_sym, *arguments)
        end
      end
      nil
    end

    # Methods for which we'd like to record example calls. Currently defined as instance methods
    # owned / defined by this object and that receive at least one argument.
    # @return [Array<Symbol>]
    def relevant_methods_names
      (instance_methods - Object.methods).select do |method_name|
        next if instance_method(method_name).arity.zero?

        next unless instance_method(method_name).owner == self

        true
      end
    end
  end
end
