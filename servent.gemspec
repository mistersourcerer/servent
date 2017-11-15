lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "servent/version"

Gem::Specification.new do |spec|
  spec.name          = "servent"
  spec.version       = Servent::VERSION
  spec.authors       = ["Ricardo Valeriano"]
  spec.email         = ["mister.sourcerer@gmail.com"]

  spec.summary       = %(Ruby Server-Sent Events client.)
  spec.description   = %(
    Provides a pure Ruby client implementation
    for Server-Sent Events
    as specified in https://www.w3.org/TR/eventsource/.
  )
  spec.homepage      = "https://github.com/mistersourcerer/servent"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "pry-byebug"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rubocop"
  spec.add_development_dependency "webmock"
end
