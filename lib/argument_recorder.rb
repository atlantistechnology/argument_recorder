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
    ArgumentRecorder::STORAGE.each_method do |method, data|
      puts "\e[44m#{data[:original_source_location].join(':').ljust(100, ' ')}\e[0m"

      instance_method = InstanceMethod.new(
        method_name: data[:name],
        source_location: data[:original_source_location],
        parameters: data[:parameters],
        examples: ArgumentRecorder::STORAGE.examples[method],
      )
      puts instance_method.to_rdoc
      puts "\n\n"

      nil
    end
  end

  # Namespace for methods added to target classes whose methods we want to record
  # @since 0.1.1
  module ClassMethods

    # Initialize examples for each relevant method by
    #  1. Notifying Storage of the method
    #  2. Alias the original method to the "original_" namespace
    #  3. Remove the original method
    #  4. Create the wrapper method
    # @return [NilClass]
    def record_arguments
      relevant_method_names.each do |method_name| # symbol

        if instance_methods.include?("__argument_recorder_#{method_name}".to_sym)
          puts "[ArgumentRecorder::ClassMethods.create_wrapper_method] WARNING! :__argument_recorder_#{method_name} ALREADY EXISTS!"
          next
        end

        # ArgumentRecorder::STORAGE.initialize_method(instance_method(method_name))

        # Copy the original method
        alias_method("__argument_recorder_#{method_name}".to_sym, method_name)

        # Remove the original method
        remove_method(method_name)

        # Redefine the method
        create_wrapper_method(method_name)
      end
      nil
    end

    # Create a wrapper method which will intercept calls, record examples, and then send the arguments on
    # to the original method
    # @param [Symbol] method_name The original method name
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
          send("__argument_recorder_#{method_name}".to_sym, *arguments, **keyword_arguments)
        else
          send("__argument_recorder_#{method_name}".to_sym, *arguments)
        end
      end
      nil
    end

    # Methods for which we'd like to record example calls. Currently defined as instance methods
    # owned / defined by this object and that receive at least one argument.
    # @return [Array<Symbol>]
    def relevant_method_names
      (instance_methods - Object.methods).select do |method_name|
        next if instance_method(method_name).arity.zero?

        # The method must be owned by the class that is calling #relevant_method_names
        next unless instance_method(method_name).owner == self

        # The method must be defined somewhere inside the current working directory
        next unless instance_method(method_name).source_location[0].include?(Dir.pwd)

        true
      end
    end
  end
end
