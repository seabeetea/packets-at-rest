module PacketsAtRest

  # directory in which daemonlogger writes files (daemonlogger -l option)
  CAPTUREDIR = '/data/pcap'

  # directory in which filer should file pcaps
  FILERDIR = '/data/filed'

  # daemonlogger capture file prefix (daemonlogger -n option)
  FILEPREFIX = 'pcap'

  # printf binary
  PRINTF = '/usr/bin/printf'

  # tcpdump binary
  TCPDUMP = '/usr/sbin/tcpdump'

  # node specification
  NODEFILE = 'nodes.conf'

  # api specification
  APIFILE = 'api.conf'
end