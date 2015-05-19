# packets-at-rest

[![GitHub release](https://img.shields.io/github/tag/packets-at-rest/packets-at-rest.svg)](https://github.com/packets-at-rest/packets-at-rest)

Packets at Rest is a RESTful web interface to pcap data on distributed network sensors through the use of IPFIX flow tuples and simple API rolebased access controls.

## Build Status

[![Build Status](https://travis-ci.org/packets-at-rest/packets-at-rest.svg)](https://travis-ci.org/packets-at-rest/packets-at-rest)
[![Code Climate](https://codeclimate.com/github/packets-at-rest/packets-at-rest/badges/gpa.svg)](https://codeclimate.com/github/packets-at-rest/packets-at-rest)
[![Test Coverage](https://codeclimate.com/github/packets-at-rest/packets-at-rest/badges/coverage.svg)](https://codeclimate.com/github/packets-at-rest/packets-at-rest)
[![Dependency Status](https://gemnasium.com/packets-at-rest/packets-at-rest.svg)](https://gemnasium.com/packets-at-rest/packets-at-rest)

## Environment and Dependencies
Suggested operating system is FreeBSD.

System dependencies include:
* net/daemonlogger

Although the Collector and the Node can exist on the same server we recommend a HA of Collectors with x-N Nodes. Collectors in a HA configuration are not aware of each other, and should be targeted via Round Robin DNS queries.

* https://www.digitalocean.com/community/tutorials/how-to-configure-dns-round-robin-load-balancing-for-high-availability

## Dependency Information

The Ruby based API is powered by sinatra and rack.

* http://www.sinatrarb.com/
* http://rack.github.io/

Packets-at-REST recommends a quality well test web server like nginx with phusion passenger.
* https://www.phusionpassenger.com/
* http://wiki.nginx.org/Main
* (NGINX+Phusion Passenger)(https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html)


## Installation

```shell
$> Bundle install
```

```shell
$> rake -T
rake bump:current    # Show current gem version
rake bump:major      # Bump major part of gem version
rake bump:minor      # Bump minor part of gem version
rake bump:patch      # Bump patch part of gem version
rake bump:pre        # Bump pre part of gem version
rake release         # release TAG 0.1.1 to github
rake role_collector  # Set Role Collector
rake role_node       # Set Role Node
rake test            # Run tests
```

Setup the mode (node|collector) for the server.

```
$> rake role_collector
```

### Node

The node is responsible for capturing the network data, storing it, and making it available to the 'node' webapp api.

Start daemonlogger. For example:

```shell
daemonlogger -i em0 -l /data/pcap/ -n pcap -t 60
```

Edit options in `config/config.rb`. For example:

```
CAPTUREDIR = '/data/pcap' # daemonlogger -l option
FILERDIR = '/data/filed'
FILEPREFIX = 'pcap' # daemonlogger -n option
````

Schedule the filer. For example, in crontab:

```cron
* * * * * /usr/local/bin/ruby /git/packets-at-rest/filer.rb
```

Start the node. For example:

```shell
rake role_node
rackup config.ru -p 9002
```

### Collector

Edit APIFILE `config/api.conf` to give API keys access to nodes. API key with access to node "0" has access to all nodes. For example:

```json
{
    "54b22f56-9a84-4893-bc70-332e3b5ded66" : [ "0" ]
}
```

Edit NODEFILE `config/nodes.conf` to associate node numbers with their addresses. For example:

```json
{
    "1" : "127.0.0.1:9002"
}
```

Start the collector. For example:

```shell
rake role_collector
rackup config.ru -p 9001
```

Make a request. For example:

```
http://127.0.0.1:9001/data.pcap?src_addr=1.1.1.1&src_port=111&dst_addr=2.2.2.2&dst_port=222&start_time=2001-01-01 5:01pm&end_time=2001-01-01 5:05pm&api_key=54b22f56-9a84-4893-bc70-332e3b5ded66&node_id=1
```

### Data Flow

![diagram](https://raw.github.com/packets-at-rest/packets-at-rest/cdn-images/diagram.png)
