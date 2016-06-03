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
end

LogShipper.config do
  sqs_queue_url 'https://sqs.us-west-2.amazonaws.com/461957644563/staging-logs'
  es_domain_url 'https://logs.telus.digital/'
  region 'us-west-2'
end

