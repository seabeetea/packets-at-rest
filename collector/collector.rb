require 'chronic'
require 'json'
require 'sys/uptime'
require 'rest_client'
require 'uri'
require_relative '../lib/pingable_server'
require_relative '../config/config'
require_relative '../lib/util'

module PacketsAtRest

  class Collector < PingableServer

    before do
      begin
        nodes = lookup_nodes_by_api_key(params['api_key'])
        if not nodes
          halt unauthorized 'unknown api_key'
        end
      rescue
        halt internalerror 'there was a problem checking api_key'
      end
    end

    get '/data.pcap' do
      begin
        packet_keys = ['src_addr', 'src_port', 'dst_addr', 'dst_port', 'start_time', 'end_time']
        other_keys = ['api_key', 'node_id']
        missing_keys = (packet_keys + other_keys).select { |k| !params.key? k }
        if not missing_keys.empty?
          return badrequest "must provide missing parameters: #{missing_keys.join(', ')}"
        end

        nodes = lookup_nodes_by_api_key(params['api_key'])
        if nodes and !nodes.include? "0" and !nodes.include? params['node_id']
          return forbidden 'api_key not allowed to request this resource'
        end

        node_address = lookup_nodeaddress_by_id params['node_id']
        if not node_address
          return badrequest 'unknown node'
        end

        query = (packet_keys << 'api_key').collect{ |k| "#{k}=#{params[k]}" }.join('&')
        uri = URI.encode("http://#{node_address}/data.pcap?#{query}")
        RestClient.get(uri) do |response, request, result|
          if response.code == 200
            content_type 'application/pcap'
          else
            content_type :json
          end
          return [response.code, response.body]
        end
      rescue
        return internalerror 'there was a problem requesting from the node'
      end
    end

    get '/keys' do
      content_type :json
      begin
        nodes = lookup_nodes_by_api_key(params['api_key'])
        if nodes.include? "0"
          return JSON.parse(File.read(APIFILE)).to_json
        else
          return forbidden 'api_key not allowed to request this resource'
        end
      rescue
        return internalerror 'there was a problem looking up nodes'
      end
    end

    get '/nodes/list' do
      content_type :json
      begin
        nodes = lookup_nodes_by_api_key(params['api_key'])
        if nodes.include? "0"
          return JSON.parse(File.read(NODEFILE)).to_json
        else
          return lookup_nodeaddresses.keep_if { |k, v| nodes.include? k }.to_json
        end
      rescue
        return internalerror 'there was a problem getting node list'
      end
    end

    get '/nodes/:node_id/ping' do
      begin
        content_type :json

        nodes = lookup_nodes_by_api_key(params['api_key'])
        if nodes and !nodes.include? "0" and !nodes.include? params['node_id']
          return forbidden 'api_key not allowed to request this resource'
        end

        node_address = lookup_nodeaddress_by_id params['node_id']
        if not node_address
          return badrequest 'unknown node'
        end

        uri = URI.encode("http://#{node_address}/ping")
        RestClient.get(uri) do |response, request, result|
          [response.code, response.body]
        end
      rescue
        return internalerror 'there was a problem requesting from the node'
      end
    end

    def lookup_nodes_by_api_key api_key
      begin
        h = JSON.parse(File.read(APIFILE))
        return h[api_key]
      rescue
        nil
      end
    end

    def lookup_nodeaddress_by_id id
      begin
        h = JSON.parse(File.read(NODEFILE))
        return h[id]
      rescue
        nil
      end
    end

    def lookup_nodeaddresses
      begin
        return JSON.parse(File.read(NODEFILE))
      rescue
        nil
      end
    end

  end

end