
# cloudformationfacts

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with cloudformationfacts](#setup)
    * [Setup requirements](#setup-requirements)
5. [Limitations - OS compatibility, etc.](#limitations)

## Description

The cloudformationfacts module provides AWS CloudFormation metadata facts which
are useful for clustered applications that need to discover other members.

## Setup

### Setup Requirements

IAM instance role with the following minimum permissions:

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

aws-sdk-core ruby gem installed on puppet agent for example:

```
/opt/puppetlabs/puppet/bin/gem install aws-sdk-core -v '~> 2'
```

## Limitations

This module would only provide facts on AWS CloudFormation stacks.
