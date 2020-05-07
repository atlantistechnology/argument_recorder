lib = File.expand_path('lib', __dir__)
unless $LOAD_PATH.include?(lib)
  $LOAD_PATH.unshift(lib)
end
require 'argument_recorder/version'

Gem::Specification.new do |spec|
  spec.name          = 'argument_recorder'
  spec.version       = ArgumentRecorder::VERSION
  spec.authors       = ['Jack Collier']
  spec.email         = ['jcollier@atlantistech.com']

  spec.summary       = 'Automatically document arguments for each of your methods.'
  spec.description   = "Passively gather information about project-defined method calls and the parameters that they're receiving in order to generate documentation"
  spec.homepage      = 'https://github.com/atlantistechnology/argument_recorder'
  spec.license       = 'MIT'
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.required_ruby_version = '>= 2.0.0'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/atlantistechnology/argument_recorder'
    spec.metadata['changelog_uri'] = 'https://github.com/atlantistechnology/argument_recorder/blob/master/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'awesome_print'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'guard', '~> 2.16'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'yard'
end
