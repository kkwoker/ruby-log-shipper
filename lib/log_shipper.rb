module LogShipper
  extend self

  def parameter(*names)
    names.each do |name|
      attr_accessor name
      define_method name do |*values|
        value = values.first
        value ? send("#{name}=", value) : instance_variable_get("@#{name}")
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
  parameter :threads
  parameter :es_client
  parameter :sqs_client
  parameter :sqs_poller
end

