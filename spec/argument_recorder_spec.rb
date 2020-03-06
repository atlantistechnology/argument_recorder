RSpec.describe ArgumentRecorder do
  class SampleClass
    include ArgumentRecorder

    def add(number1, number2)
      number1 + number2
    end

    def display_icon(kind: 'alert', message:)
      "#{kind} : #{message}"
    end

    record_arguments
  end

  it 'has a version number' do
    expect(ArgumentRecorder::VERSION).not_to be nil
  end

  it 'calls method with simple required arguments' do
    puts "1 plus 5 is #{SampleClass.new.add(1, 5)}"
    puts "2 plus 9 is #{SampleClass.new.add(2, 9)}"
    puts "3 plus 27 is #{SampleClass.new.add(3, 27)}"
  end

  it 'calls method with a keyword containing default' do
    puts SampleClass.new.display_icon(kind: :notice, message: "It's OK")
    puts SampleClass.new.display_icon(kind: :alert, message: 'SOMETHING IS WRONG')
  end

  it 'recorded something' do
    expect(SampleClass.instance_variable_get(:@argument_recordings)).to eq({ add: {} })
  end
end
