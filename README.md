# Puppet module providing AWS CloudFormation metadata facts

## Pre-requisites:

- IAM instance role with the following minimum permissions:

```
{
   "Version": "2012-10-17",
   "Statement": [{
      "Effect": "Allow",
      "Action": [
         "ec2:DescribeInstances",
         "ec2:DescribeTags"
      ],
      "Resource": "*"
   }
   ]
}
```

- aws-sdk-core ruby gem installed on puppet agent for example:

```
/opt/puppetlabs/puppet/bin/gem install aws-sdk-core
```