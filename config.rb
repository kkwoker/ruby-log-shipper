require_relative 'lib/log_shipper'

LogShipper.config do
  sqs_queue_url 'https://sqs.us-west-2.amazonaws.com/461957644563/staging-logs'
  es_domain_url 'https://search-production-logs-o5b3ar4zedvoc3j73jgufldvca.us-east-1.es.amazonaws.com'
  region 'us-west-2'
  threads 1
  debug true

  es_client Elasticsearch::Client.new(
    host: LogShipper.es_domain_url,
    #  log: true,
    adapter: :net_http_persistent
  )
  sqs_client Aws::SQS::Client.new(region: LogShipper.region)
  sqs_poller Aws::SQS::QueuePoller.new(
    LogShipper.sqs_queue_url,
    client: LogShipper.sqs_client,
    max_number_of_messages: 10
  )
end

LogShipper.sqs_poller.before_request do |stats|
  Announce.info "#{stats.last_message_received_at} requests: #{stats.request_count} messages: #{stats.received_message_count}"
end
