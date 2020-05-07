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

    def with_splat(*args)
      "args is #{args}"
    end

    def mixed_arguments(param_a, options)
      "#{param_a} #{options.map { |key, value| "#{key}:#{value}" }.join}"
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

  it 'calls method with a splat' do
    expect(SampleClass.new.with_splat(['a'])).to eq 'args is [["a"]]'
    expect(SampleClass.new.with_splat('a')).to eq 'args is ["a"]'
    expect(SampleClass.new.with_splat('a', 'b')).to eq 'args is ["a", "b"]'
  end

  it 'calls method with a block' do
    expect do |probe|
      SampleClass.new.explore(&probe)
    end.to yield_with_args 'result'
  end

  it 'calls with mixed arguments' do
    expect(SampleClass.new.mixed_arguments('name', { precision: 2 })).to eq 'name precision:2'
  end

  it 'recorded something' do
    ArgumentRecorder.display_argument_data
  end
end
