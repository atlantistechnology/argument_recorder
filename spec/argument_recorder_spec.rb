RSpec.describe ArgumentRecorder do
  class SampleClass
    include ArgumentRecorder

    def add(number1, number2)
      number1 + number2
    end
    
    def display_icon(kind: 'alert', message:)
      "#{kind} : #{message}"
    end
    
    def with_default(param_a, param_b = false)
      "param_a is #{param_a}, param_b is #{param_b}"
    end
    
    def explore(&block)
      block.call('result')
    end
    
    record_arguments
  end

  it 'has a version number' do
    expect(ArgumentRecorder::VERSION).not_to be nil
  end

  it 'calls method with simple required arguments' do
    expect(SampleClass.new.add(1, 5)).to eq 6
    expect(SampleClass.new.add(2, 9)).to eq 11
    expect(SampleClass.new.add(3, 27)).to eq 30
  end

  it 'calls method with a keyword containing default' do
    expect(SampleClass.new.display_icon(kind: :success, message: 'The object was created successfully.'))
      .to eq('success : The object was created successfully.')
    expect(SampleClass.new.display_icon(kind: :notice, message: 'The object is invalid.'))
      .to eq('notice : The object is invalid.')
    expect(SampleClass.new.display_icon(kind: :alert, message: 'There was a profound error!'))
      .to eq('alert : There was a profound error!')
  end

  it 'calls method with a default' do
    expect(SampleClass.new.with_default('a')).to eq 'param_a is a, param_b is false'
    expect(SampleClass.new.with_default('c', true)).to eq 'param_a is c, param_b is true'
  end

  it 'calls method with a block' do
    expect do |probe|
      SampleClass.new.explore(&probe)
    end.to yield_with_args 'result'
  end

  it 'recorded something' do
    SampleClass.display_argument_data
  end
end
