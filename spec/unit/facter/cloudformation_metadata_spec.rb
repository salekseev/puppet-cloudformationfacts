require 'spec_helper'
require 'facter'

describe :cloudformation_metadata, :type => :fact do

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      # Add the 'foo' fact with the value 'bar' to the tests
      let(:facts) do
        facts.merge(
          :ec2_metadata => {
            'iam' => {
              'info' => {
                'Code' => 'Success'
              }
            },
            'instance-id' => 'i-063e663e3b2e8ef0f',
            'local-ipv4' => '10.129.4.163',
            'placement' => {
              'availability-zone' => 'us-east-1a'
            }
          }
        )
      end

      Aws.config[:ec2] = {
        stub_responses: {
          describe_tags: { buckets: [{name: 'my-bucket' }] }
        }
      }

      it 'should return a value' do
        expect(Facter.fact(:cloudformation_metadata).value).to eq('value123')  #<-- change the value to match your expectation
      end
    end
  end

end
