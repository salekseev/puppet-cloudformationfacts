require 'spec_helper'
require 'facter'

describe :cloudformation_metadata, :type => :fact do

  before :all do
    # perform any action that should be run for the entire test suite
  end

  before :each do
    # perform any action that should be run before every test
    Facter.clear
    # This will mock the facts that confine uses to limit facts running under certain conditions
    allow(Facter.fact(:kernel)).to receive(:value).and_return("Linux")
    # below is how you mock responses from the command line
    # you will need to built tests that plugin different mocked values in order to fully test your facter code
  
    allow(Facter::Core::Execution).to receive(:execute).with("echo 'value123'").and_return('mocked_value123')
  end

  it 'should return a value' do
    expect(Facter.fact(:cloudformation_metadata).value).to eq('value123')  #<-- change the value to match your expectation
  end
end
