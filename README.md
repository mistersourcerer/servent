# Servent

[<img src="https://travis-ci.org/mistersourcerer/servent.svg?branch=master" />](https://travis-ci.org/mistersourcerer/servent)

Ruby _Server-Sent Events_ client.
An _EventSource_ Ruby implementation
based on the [W3C specification](https://www.w3.org/TR/eventsource).

## Early Development [15/11/2017]

This is just a first public draft,
a bunch of changes and lack of documentation
is to be expected.

### Install

Add this line to your application's Gemfile:

```ruby
gem 'servent'
```

Or use _rubygems_:

    $ gem install servent

## Usage

```ruby
# given that the http://example.org/event-source
# generates an event like the one below:
#
#   event: hello_world
#   id: 42
#   data: Omg! Hello World.

event_source = Servent::EventSource.new("http://example.org/event-source")
event_source.on_message do |message|
  puts "Event type: #{event.type}"
  puts "Event body: #{event.data}"

  # Will print:
  #
  #   ```
  #     Event type: hello_world
  #     Event body: Omg! Hello World.
  #   ```
  # And wait for the next event to arrive.
end

# join the internal event source thread
# so we can receive event until it terminates:
event_source.listen
```

## More examples

There is directory `examples` in this project
with a _WEBrick_ server
and also a `EventSource` consumer.

### How to run the example

#### TL;DR
    $ cd examples

    # on one terminal:
    $ rackup

    # on a second one:
    $ ruby consumer.rb

    # on yeat another one
    $ curl http://localhost:9292/broadcast

    # and to make the consumer close itself:
    $ curl http://localhost:9292/enough

#### More detailed version

if you are inside the directory
(or copied the files in the example dir to your own)
you can run a _rackup_:

    $ rackup

The server will run on port _9292_
and it has 3 endpoints:

    /
    /broadcast
    /enough

The root (`/`) is intended to consumers
and the one in the example
starts listening to that endpoint like this:

```ruby
event_source = Servent::EventSource.new("http://localhost:9292/")
# ...
event_source.listen
```

If you want to test multiple messages arriving
you can use the `repeat` parameters in the request:

    $ curl http://localhost/broadcast?repeat=3

## TODO:
- [ ] Hit the proxy when response asks for it and credentials are available.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ricardovaleriano/servent. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Servent project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/ricardovaleriano/servent/blob/master/CODE_OF_CONDUCT.md).
