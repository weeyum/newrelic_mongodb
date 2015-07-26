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
          command = Proc.new { logging_without_newrelic_trace(messages, operation_id) }

          operation_type = case operation_name.to_s
            when *%w(delete) then 'destroy'
            when *%w(find get_more query) then 'find'
            when *%w(insert update) then 'save'
            else
              nil
            end

          if operation_type
            callback = Proc.new do |result, metric, elapsed|
              NewRelic::Agent::Datastores.notice_statement(operation_name, elapsed)
            end

            NewRelic::Agent::Datastores.wrap('MongoDB', operation_type, collection_name, callback) do
              command.call
            end
          else
            command.call
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
