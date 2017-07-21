# salekseev-cloudformationfacts

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with [Modulename]](#setup)
    * [Setup requirements](#setup-requirements)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Overview

The cloudformationfacts module provides AWS CloudFormation metadata facts.

## Module Description

The cloudformationfacts module provides AWS CloudFormation metadata facts which
are useful for clustered applications that need to discover other members.

## Setup

### Setup requirements

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
/opt/puppetlabs/puppet/bin/gem install aws-sdk-core
```

## Limitations

This module would only provide facts on AWS CloudFormation stacks.

## Development

https://github.com/salekseev/puppet-cloudformationfacts/blob/master/DEVELOPMENT.md
