# ArgumentRecorder

This tool should be able to hook into a running ruby application and passively gather information about project-defined method calls and the parameters that they're receiving in order to generate documentation for each method along with real-world sample values.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'argument_recorder'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install argument_recorder

## Usage

```
require 'argument_recorder'

class YourClass
  include ArgumentRecorder
  
  def your_method_definition(param1)
  	# ...
  end
  
  def another_method_definition(keyword_a:, keyword_b: :active)
  	# ...
  end
  
  # This goes at the bottom of your class definition!
  record_arguments
end

YourClass.new.your_method_definition('Awesome!')
YourClass.new.another_method_definition(keyword_a: 'Ben Folds', keyword_b: :very_active)

ArgumentRecorder.display_argument_data
```

```
# In a Rails project
class ApplicationController < ActionController::Base
  after_action :display_arguments

  # Your actions

  private

  def display_arguments
    ArgumentRecorder.display_argument_data
  end
end
```

## TODO
* Investigate better ways of doing the metaprogramming
* Record Caller information in Examples
* Evolve Storage

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/atlantistechnology/argument_recorder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ArgumentRecorder project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/atlantistechnology/argument_recorder/blob/master/CODE_OF_CONDUCT.md).
