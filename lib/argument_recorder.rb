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

  # Formatted contents of `ArgumentRecorder::STORAGE`
  #
  # @return [String]
  def self.formatted_argument_data
    return_string = ''

    ArgumentRecorder::STORAGE.each_method do |method, data|
      return_string << formatted_information_for_method(method, data)
    end

    return_string
  end

  # puts formatted contents of `ArgumentRecorder::STORAGE`
  #
  # @return [nil]
  def self.display_argument_data
    puts formatted_argument_data
  end

  # Details about a given method
  #
  # @param [UnboundMethod] method
  # @param [Hash] data
  #
  # @example
  #    'Defined: /var/project/argument_recorder/spec/inherited_class_spec.rb:5
  #    Called from:
  #    * /var/project/argument_recorder/spec/inherited_class_spec.rb:17
  #    #  #add [line 5]
  #    #
  #    #  @example
  #    #    add(1, 5)
  #    #
  #    #  @param [Integer] number1
  #    #  @param [Integer] number2'
  #
  # @return [String]
  def self.formatted_information_for_method(method, data)
    return_string = "\e[44mDefined: #{data[:original_source_location].join(':').ljust(100, ' ')}\e[0m\n"

    return_string << [
      "\e[32mCalled from:\n", # green
      ArgumentRecorder::STORAGE.lines_where_method_was_called(method).join("\n"),
      "\e[0m\n", # end green
    ].join

    instance_method = InstanceMethod.new(
      method_name: data[:name],
      source_location: data[:original_source_location],
      parameters: data[:parameters],
      examples: ArgumentRecorder::STORAGE.examples[method],
    )
    return_string << instance_method.to_rdoc
    return_string << "\n\n"
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
          calling_line: caller[0],
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
        next if method_name =~ /__argument_recorder/

        instance_method = instance_method(method_name)

        next if instance_method.arity.zero?

        # The method must be owned by the class that is calling #relevant_method_names
        next unless instance_method.owner == self

        # The method must be defined somewhere inside the current working directory
        next unless instance_method.source_location[0].include?(Dir.pwd)

        true
      end
    end
  end
end
