# Servent

[<img src="https://travis-ci.com/mistersourcerer/servent.svg?token=aMwiRm3UQ11zdWwMxGgZ&branch=master" />](https://travis-ci.com/mistersourcerer/servent)

Ruby _Server-Sent Events_ client.
A _EventSource_ Ruby implementation based on the [W3C specification](https://www.w3.org/TR/eventsource).

## Early Development [15/11/2017]

This is just a first public draft,
a bunch of changes and lack of documentation
is to be expected.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'servent'
```

## Usage

```ruby
# given that the http://example.org/event-source
# generates an event like the one below:
#
#   event: hello_world
#   id: 42
#   data: Omg! Hello World.

events = Queue.new

event_source = Servent::EventSource.new("http://example.org/event-source")
event_source.on_message do |message|
  events.push message
end
event_source.start

while (event = events.pop)
  puts "Event type: #{event.type}"
  puts "Event body: #{event.body}"

  # Will print:
  #
  #   ```
  #     Event type: hello_world
  #     Event body: Omg! Hello World.
  #   ```
  # And wait for the next event to arrive.
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ricardovaleriano/servent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Servent project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ricardovaleriano/servent/blob/master/CODE_OF_CONDUCT.md).
