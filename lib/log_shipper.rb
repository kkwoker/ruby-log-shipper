module LogShipper
  extend self

  def parameter(*names)
    names.each do |name|
      attr_accessor name
      define_method name do |*values|
        value = values.first
        value ? self.send("#{name}=", value) : instance_variable_get("@#{name}")
      end
    end
  end

  def config(&block)
    instance_eval &block
  end

end

LogShipper.config do
  parameter :sqs_queue_url
  parameter :es_domain_url
  parameter :region
  parameter :es_client
  parameter :sqs_client
  parameter :sqs_poller
end

LogShipper.config do
  sqs_queue_url 'https://sqs.us-west-2.amazonaws.com/461957644563/staging-logs'
  es_domain_url 'https://logs.telus.digital/'
  region 'us-west-2'
end

LogShipper.config do
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
  Announce.info "requests: #{stats.request_count}"
  Announce.info "messages: #{stats.received_message_count}"
  Announce.info "last-timestamp: #{stats.last_message_received_at}"
end
