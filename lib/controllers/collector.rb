module PacketsAtRest
    module Controllers
        class Collector
            def initialize(opts = {})
                @apifile = opts[:apifile] || PacketsAtRest::APIFILE
                @nodefile = opts[:nodefile] || PacketsAtRest::NODEFILE
            end

            def lookup_nodes_by_api_key(api_key)
              begin
                h = JSON.parse(File.read(@apifile))
                return h[api_key]
              rescue
                nil
              end
            end

            def lookup_nodeaddress_by_id(id)
              begin
                h = JSON.parse(File.read(@nodefile))
                return h[id]
              rescue
                nil
              end
            end

            def lookup_nodeaddresses
              begin
                return JSON.parse(File.read(@nodefile))
              rescue
                nil
              end
            end

        end
    end
end