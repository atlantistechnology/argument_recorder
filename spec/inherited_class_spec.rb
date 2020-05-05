RSpec.describe ArgumentRecorder do
  class ParentClass
    include ArgumentRecorder

    def add(number1, number2)
      number1 + number2
    end

    record_arguments
  end

  class ChildClass < ParentClass
  end

  it 'calls method with simple required arguments' do
    expect do
      expect(ChildClass.new.add(1, 5)).to eq 6
    end.not_to raise_error
  end

  it 'recorded something' do
    ArgumentRecorder.display_argument_data
  end
end
