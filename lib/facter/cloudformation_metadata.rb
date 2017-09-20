# This fact would produce a hash of cloudformation metadata based on instance
# tags and will use IAM role to do so
Facter.add(:cloudformation_metadata) do
  # use the confine feature to lock a fact to only run if aws-sdk-core gem
  # is available
  confine do
    begin
      require 'aws-sdk-core'
      true
    rescue LoadError
      false
    end
  end

  # use the confine feature to lock a fact to only run if IAM role is set
  confine do
    Facter.value(:ec2_metadata)['iam']['info']
  end

  setcode do
    metadata = {}

    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region, retry_limit: 10)

    # outputs: string
    begin
      resp = ec2.describe_tags(
        filters: [
          {
            name: 'resource-type',
            values: ['instance'],
          },
          {
            name: 'resource-id',
            values: [instance_id],
          },
          {
            name: 'key',
            values: ['aws:autoscaling:groupName'],
          },
        ],
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        metadata['autoscaling-groupname'] = resp[:tags][0][:value]
      else
        raise "More than 2 tags matched the filter. Strictly speaking, this shouldn't happen"
      end
    rescue Aws::EC2::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Compute Cloud
      puts "Failure in cloudformation.autoscaling-groupname fact: #{e}"
      nil
    end

    # outputs: array
    begin
      resp = ec2.describe_tags(
        filters: [
          {
            name: 'resource-type',
            values: ['instance'],
          },
          {
            name: 'resource-id',
            values: [instance_id],
          },
          {
            name: 'key',
            values: ['aws:autoscaling:groupName'],
          },
        ],
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        resp2 = ec2.describe_instances(
          filters: [
            {
              name: 'tag:aws:autoscaling:groupName',
              values: [resp[:tags][0][:value]],
            },
          ],
        )
        metadata['autoscaling-group-local-ipv4s'] = []
        resp2[:reservations].each do |reservations|
          reservations[:instances].each do |instances|
            instances[:network_interfaces].each do |network_interfaces|
              network_interfaces[:private_ip_addresses].each do |private_ip_addresses|
                metadata['autoscaling-group-local-ipv4s'] << private_ip_addresses[:private_ip_address]
              end
            end
          end
        end
      else
        raise "More than 2 tags matched the filter. Strictly speaking, this shouldn't happen"
      end
    rescue Aws::EC2::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Compute Cloud
      puts "Failure in cloudformation.autoscaling-group-local-ipv4s fact: #{e}"
      nil
    end

    # outputs: string
    begin
      resp = ec2.describe_tags(
        filters: [
          {
            name: 'resource-type',
            values: ['instance'],
          },
          {
            name: 'resource-id',
            values: [instance_id],
          },
          {
            name: 'key',
            values: ['aws:cloudformation:stack-name'],
          },
        ],
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        metadata['stack-name'] = resp[:tags][0][:value]
      else
        raise "More than 2 tags matched the filter. Strictly speaking, this shouldn't happen"
      end
    rescue Aws::EC2::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Compute Cloud
      puts "Failure in cloudformation.stack-name fact: #{e}"
      nil
    end

    # outputs: array
    begin
      resp = ec2.describe_tags(
        filters: [
          {
            name: 'resource-type',
            values: ['instance'],
          },
          {
            name: 'resource-id',
            values: [instance_id],
          },
          {
            name: 'key',
            values: ['aws:cloudformation:stack-id'],
          },
        ],
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        resp2 = ec2.describe_instances(
          filters: [
            {
              name: 'tag:aws:cloudformation:stack-id',
              values: [resp[:tags][0][:value]],
            },
          ],
        )
        metadata['stack-local-ipv4s'] = []
        resp2[:reservations].each do |reservations|
          reservations[:instances].each do |instances|
            instances[:network_interfaces].each do |network_interfaces|
              network_interfaces[:private_ip_addresses].each do |private_ip_addresses|
                metadata['stack-local-ipv4s'] << private_ip_addresses[:private_ip_address]
              end
            end
          end
        end
      else
        raise "More than 2 tags matched the filter. Strictly speaking, this shouldn't happen"
      end
    rescue Aws::EC2::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Compute Cloud
      puts "Failure in cloudformation.stack-local-ipv4s fact: #{e}"
      nil
    end

    metadata
  end
end
