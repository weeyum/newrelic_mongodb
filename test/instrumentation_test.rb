require 'test/unit'
require 'mongo'

require File.expand_path(File.dirname(__FILE__) + '/../lib/newrelic_mongodb/instrumentation')

require 'newrelic_rpm'
NewRelic::Agent.require_test_helper

class TestInstrumentation < Test::Unit::TestCase
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  def setup
    @client = Mongo::Client.new('mongodb://127.0.0.1:27017', database: 'newrelic_mongodb_test')
    @client.database[:artists].insert_one(name: 'Syd Vicious')

    NewRelic::Agent.drop_buffered_data
  end

  def teardown
    @client.database[:artists].drop
    NewRelic::Agent.drop_buffered_data
  end

  def assert_generated_metrics(types)
    expected_metrics = %w(Datastore/MongoDB/all Datastore/MongoDB/allOther Datastore/all Datastore/allOther)
    expected_metrics += types.flat_map { |type| ["Datastore/operation/MongoDB/#{type}",  "Datastore/statement/MongoDB/artists/#{type}"] }

    assert_metrics_recorded_exclusive(expected_metrics)
  end

  def test_command_is_passed
    assert_equal(@client.database[:artists].find(name: 'Syd Vicious').count, 1)

    assert_generated_metrics(%w(count))
  end

  def test_aggregate_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').aggregate([{ '$group' => { _id: '$name' } }]).to_a

    assert_generated_metrics(%w(aggregate))
  end

  # TODO: update travis CI to use newest mongo version
  # def test_parallel_scan_generates_metrics
  #   @client.database[:artists].find(name: 'Syd Vicious').parallel_scan(2).to_a

  #   assert_generated_metrics(%w(getmore parallelCollectionScan))
  # end

  def test_count_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').count

    assert_generated_metrics(%w(count))
  end

  def test_distinct_metrics
    @client.database[:artists].find(name: 'Syd Vicious').distinct('name')

    assert_generated_metrics(%w(distinct))
  end

  def test_map_reduce_metrics
    @client.database[:artists].find(name: 'Syd Vicious').map_reduce('function() { emit(this.name, 1); }', 'function(key, values) { return Array.sum(values) }').to_a

    assert_generated_metrics(%w(mapreduce))
  end

  def test_get_more_metrics
    5.times { @client.database[:artists].insert_one(name: 'Syd Vicious') }
    @client.database[:artists].find.batch_size(2).to_a

    assert_generated_metrics(%w(insert find getmore))
  end

  def test_delete_many_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').delete_many

    assert_generated_metrics(%w(delete))
  end

  def test_delete_one_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').delete_one

    assert_generated_metrics(%w(delete))
  end

  def test_find_one_and_delete_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').find_one_and_delete

    assert_generated_metrics(%w(findandmodify))
  end

  def test_find_one_and_replace_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').find_one_and_replace(name: 'William Li')

    assert_generated_metrics(%w(findandmodify))
  end

  def test_find_one_and_update_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').find_one_and_update(name: 'William Li')

    assert_generated_metrics(%w(findandmodify))
  end

  def test_replace_one_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').replace_one(name: 'William Li')

    assert_generated_metrics(%w(update))
  end

  def test_update_many_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').update_many('$set' => { name: 'William Li' })

    assert_generated_metrics(%w(update))
  end

  def test_update_one_generates_metrics
    @client.database[:artists].find(name: 'Syd Vicious').update_one('$set' => { name: 'William Li' })

    assert_generated_metrics(%w(update))
  end
end
