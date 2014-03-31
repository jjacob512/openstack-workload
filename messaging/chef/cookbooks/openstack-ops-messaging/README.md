# Description #

This cookbook provides shared message queue configuration for the OpenStack **Havana** reference deployment provided by Chef for OpenStack. The http://github.com/mattray/chef-openstack-repo contains documentation for using this cookbook in the context of a full OpenStack deployment. It currently supports RabbitMQ and will soon other queues.

# Requirements #

Chef 11 with Ruby 1.9.x required.

# Platforms #

* Ubuntu-12.04

# Cookbooks #

The following cookbooks are dependencies:

* openstack-common
* rabbitmq

# Usage #

The usage of this cookbook is optional, you may choose to set up your own messaging service without using this cookbook. If you choose to do so, you will need to provide all of the attributes listed under the [Attributes](#attributes).

# Resources/Providers #

None

# Templates #

None

# Recipes #

## server ##

- message queue server configuration, selected by attributes

## rabbitmq-server ##

- configures the RabbitMQ server for OpenStack

# Attributes #

* `openstack["mq"]["cluster"]` - whether or not to cluster rabbit, defaults to 'false'

Testing
=====

Please refer to the [TESTING.md](TESTING.md) for instructions for testing the cookbook.

Berkshelf
=====

Berks will resolve version requirements and dependencies on first run and
store these in Berksfile.lock. If new cookbooks become available you can run
`berks update` to update the references in Berksfile.lock. Berksfile.lock will
be included in stable branches to provide a known good set of dependencies.
Berksfile.lock will not be included in development branches to encourage
development against the latest cookbooks.

License and Author
==================

|                      |                                                    |
|:---------------------|:---------------------------------------------------|
| **Author**           |  John Dewey (<john@dewey.ws>)                      |
| **Author**           |  Matt Ray (<matt@opscode.com>)                     |
| **Author**           |  Craig Tracey (<craigtracey@gmail.com>)            |
| **Author**           |  Ionut Artarisi (<iartarisi@suse.cz>)              |
| **Author**           |  JieHua Jin (<jinjhua@cn.ibm.com>)                 |
|                      |                                                    |
| **Copyright**        |  Copyright (c) 2013, Opscode, Inc.                 |
| **Copyright**        |  Copyright (c) 2013, Craig Tracey                  |
| **Copyright**        |  Copyright (c) 2013, AT&T Services, Inc.           |
| **Copyright**        |  Copyright (c) 2013, SUSE Linux  GmbH.             |
| **Copyright**        |  Copyright (c) 2013, IBM Corp.                     |



Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
