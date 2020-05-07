# Changelog

## [0.1.5] - 2020-05-07
### Added
* Now recording (and displaying) the first line of the #caller.
### Fixed
* Methods which take a Hash as a second parameter are confused with keywords. This prevents original code from breaking, but still creates some problems for us that have to be addressed - specifically around identifying @param types.
### Removed
* Rubocop as a dev dependency

## [0.1.4] - 2020-05-06
### Changed
* Separate @methods and @examples in storage
* The new UnboundMethod itself is now the key for storage operations. Class names and method names were not playing well with inheritence and the dynamic nature of ruby classes.
* Updated documentation

## [0.1.3] - 2020-05-04
### Added
* Handle *splats
### Changed
* Change namespacing of dyamically redefined methods
* Update Readme

## [0.1.2] - 2020-04-29
### Added
* Storage: receive and handle data sent by the recorder
* InstanceMethod: a single instance method on any class
* ExampleCall: a single call to a given method and the parameter values that were passed
* Added various development gem dependencies
* Added rdoc documentation

## [0.1.1] - 2020-04-29
### Added
* Github Actions for testing via rspec
### Changed
* Handle ruby versions > 2.3

## [0.1.0] - 2020-04-29
### Added
* Basic ability to gather examples of method calls and record their arguments
* Rudimentary handling for some ruby version variations