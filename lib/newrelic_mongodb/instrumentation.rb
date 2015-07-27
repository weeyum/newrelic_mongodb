require 'new_relic/agent/method_tracer'
require 'new_relic/agent/datastores'

DependencyDetection.defer do
  @name = :mongodb

  depends_on do
    defined?(::Mongo) && defined?(::Mongo::Server::Connection)
  end

  executes do
    NewRelic::Agent.logger.info 'Installing Mongodb instrumentation'
  end

  executes do
    Mongo::Server::Connection.class_eval do
      include NewRelic::Agent::Instrumentation::Mongodb

      alias_method :logging_without_newrelic_trace, :dispatch
      alias_method :dispatch, :logging_with_newrelic_trace
    end
  end
end

module NewRelic
  module Agent
    module Instrumentation
      module Mongodb
        def logging_with_newrelic_trace(messages, operation_id = nil)
          operation_name, collection_name = determine_operation_and_collection(messages.first)

          NewRelic::Agent::Datastores.wrap('MongoDB', operation_name, collection_name, ->(result, metric, elapsed){ NewRelic::Agent::Datastores.notice_statement(operation_name, elapsed) }) do
            logging_without_newrelic_trace(messages, operation_id)
          end
        end

        private
        def determine_operation_and_collection(message)
          operation_name = message.payload[:command_name]

          collection_name = if (namespace_name = message.namespace.split('.').last) == '$cmd'
            message.selector[operation_name]
          else
            namespace_name
          end

          [operation_name, collection_name]
        end
      end
    end
  end
end
