require 'ostruct'
require 'test/unit'
require 'mongo'

require File.expand_path(File.dirname(__FILE__) + '/../lib/newrelic_mongodb/instrumentation')

require 'newrelic_rpm'
NewRelic::Agent.require_test_helper

class TestInstrumentation < Test::Unit::TestCase
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def setup
    @client = Mongo::Client.new('mongodb://127.0.0.1:27017', database: 'newrelic_mongodb_test')

    NewRelic::Agent.drop_buffered_data
  end

  def test_generates_metrics
    @client.database[:artists].insert_one(name: 'Syd Vicious')
    @client.database[:artists].find(name: 'Syd Vicious').to_a
    @client.database[:artists].find(name: 'Syd Vicious').update_one(name: 'William Li')
    @client.database[:artists].find(name: 'Syd Vicious').update_one(name: 'William Li')
    @client.database[:artists].find(name: 'William Li').delete_one

    assert_metrics_recorded_exclusive([
      'Datastore/MongoDB/all',
      'Datastore/MongoDB/allOther',
      'Datastore/all',
      'Datastore/allOther',
      'Datastore/operation/MongoDB/destroy',
      'Datastore/operation/MongoDB/find',
      'Datastore/operation/MongoDB/save',
      'Datastore/statement/MongoDB/artists/destroy',
      'Datastore/statement/MongoDB/artists/find',
      'Datastore/statement/MongoDB/artists/save'
    ])
  end
end
