# New Relic Mongodb
[![Gem Version](https://badge.fury.io/rb/newrelic_mongodb.svg)](https://badge.fury.io/rb/newrelic_mongodb.svg)
[![Build Status](https://travis-ci.org/weeyum/newrelic_mongodb.svg)](https://travis-ci.org/weeyum/newrelic_mongodb)
[![Coverage Status](https://coveralls.io/repos/weeyum/newrelic_mongodb/badge.svg?branch=master&service=github)](https://coveralls.io/github/weeyum/newrelic_mongodb?branch=master)

New Relic instrumentation for Mongo (2.1.0) / Mongoid (5.x)

## Important

This gem is compatible only with __newrelic_rpm__ >= 3.11

## Installation

Add this line to your application's Gemfile:

    gem 'newrelic_mongodb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install newrelic_mongodb

### Configuration

This gem does not require any specific configuration. Please follow general newrelic_rpm gem configuration:
https://github.com/newrelic/rpm/blob/master/newrelic.yml

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request