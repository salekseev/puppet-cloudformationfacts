# This fact would produce a hash of cloudformation metadata based on instance
# tags and will use IAM role to do so
Facter.add(:cloudformation_metadata, :type => :aggregate) do
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

  # outputs: string
  chunk :autoscaling_groupname do
    metadata = {}
    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    begin
      resp = ec2.describe_tags(
        filters: [{
          name: 'resource-type',
          values: ['instance']
        }, {
          name: 'resource-id',
          values: [instance_id]
        }, {
          name: 'key',
          values: ['aws:autoscaling:groupName']
        }]
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
      Facter::Core::Logging.warn("Failure in cloudformation.autoscaling-groupname fact: #{e}")
      nil
    end
    metadata
  end

  # outputs: array
  chunk :autoscaling_group_local_ipv4s do
    metadata = {}
    metadata['autoscaling-group-local-ipv4s'] = []
    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    begin
      resp = ec2.describe_tags(
        filters: [{
          name: 'resource-type',
          values: ['instance']
        }, {
          name: 'resource-id',
          values: [instance_id]
        }, {
          name: 'key',
          values: ['aws:autoscaling:groupName']
        }]
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        resp2 = ec2.describe_instances(
          filters: [{
            name: 'tag:aws:autoscaling:groupName',
            values: [resp[:tags][0][:value]]
          }]
        )
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
      Facter::Core::Logging.warn("Failure in cloudformation.autoscaling-group-local-ipv4s fact: #{e}")
      nil
    end
    metadata
  end

  # outputs: boolean
  chunk :is_first_member_of_autoscaling_group, :require => :autoscaling_group_local_ipv4s do |autoscaling_group_local_ipv4s|
    metadata = {}
    local_ipv4 = Facter.value(:ec2_metadata)['local-ipv4']
    begin
      metadata['is_first_member_of_autoscaling_group'] =
        local_ipv4 == autoscaling_group_local_ipv4s.first && !local_ipv4.nil?
    end
    metadata
  end

  # outputs string
  chunk :logical_id do
    metadata = {}
    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    begin
      resp = ec2.describe_tags(
        filters: [{
          name: 'resource-type',
          values: ['instance']
        }, {
          name: 'resource-id',
          values: [instance_id]
        }, {
          name: 'key',
          values: ['aws:cloudformation:logical-id']
        }]
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        metadata['logical-id'] = resp[:tags][0][:value]
      else
        raise "More than 2 tags matched the filter. Strictly speaking, this shouldn't happen"
      end
    rescue Aws::EC2::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Compute Cloud
      Facter::Core::Logging.warn("Failure in cloudformation.logical-id fact: #{e}")
      nil
    end
    metadata
  end

  # outputs: string
  chunk :stack_id do
    metadata = {}
    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    begin
      resp = ec2.describe_tags(
        filters: [{
          name: 'resource-type',
          values: ['instance']
        }, {
          name: 'resource-id',
          values: [instance_id]
        }, {
          name: 'key',
          values: ['aws:cloudformation:stack-id']
        }]
      )
      if resp.tags.length.zero?
        Facter::Core::Logging.debug('No cloudformation tag found')
        nil
      elsif resp.tags.length == 1
        metadata['stack-id'] = resp[:tags][0][:value]
      else
        raise "More than 2 tags matched the filter. Strictly speaking, this shouldn't happen"
      end
    rescue Aws::EC2::Errors::ServiceError => e
      # rescues all errors returned by Amazon Elastic Compute Cloud
      Facter::Core::Logging.warn("Failure in cloudformation.stack-id fact: #{e}")
      nil
    end
    metadata
  end

  # outputs: string
  chunk :stack_name do
    metadata = {}
    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    begin
      resp = ec2.describe_tags(
        filters: [{
          name: 'resource-type',
          values: ['instance']
        }, {
          name: 'resource-id',
          values: [instance_id]
        }, {
          name: 'key',
          values: ['aws:cloudformation:stack-name']
        }]
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
      Facter::Core::Logging.warn("Failure in cloudformation.stack-name fact: #{e}")
      nil
    end
    metadata
  end

  # outputs: array
  chunk :stack_local_ipv4s do
    metadata = {}
    metadata['stack-local-ipv4s'] = []
    instance_id = Facter.value(:ec2_metadata)['instance-id']
    region = Facter.value(:ec2_metadata)['placement']['availability-zone'][0..-2]
    ec2 = Aws::EC2::Client.new(region: region)
    begin
      resp = ec2.describe_tags(
        filters: [{
          name: 'resource-type',
          values: ['instance']
        }, {
          name: 'resource-id',
          values: [instance_id]
        }, {
          name: 'key',
          values: ['aws:cloudformation:stack-id']
        }]
      )
      if resp.tags.length.zero?
        nil
      elsif resp.tags.length == 1
        resp2 = ec2.describe_instances(
          filters: [{
            name: 'tag:aws:cloudformation:stack-id',
            values: [resp[:tags][0][:value]]
          }]
        )
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
      Facter::Core::Logging.warn("Failure in cloudformation.stack-local-ipv4s fact: #{e}")
      nil
    end
    metadata
  end
end
