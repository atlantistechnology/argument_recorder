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
class YourClass
  include ArgumentRecorder
  
  def your_method_definition
  	# ...
  end
  
  def another_method_definition
  	# ...
  end
  
  # This goes at the bottom of your class definition!
  record_arguments
end
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/atlantistechnology/argument_recorder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the ArgumentRecorder project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/atlantistechnology/argument_recorder/blob/master/CODE_OF_CONDUCT.md).
