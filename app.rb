require 'net/http'
require 'influxdb'
require 'date'

influxdb = InfluxDB::Client.new host: '192.168.0.9', database: 'squid'

Net::HTTP.start('127.0.0.1', 3128) do |http|
  while true

    request = Net::HTTP::Get.new 'cache_object://localhost/active_requests'

    response = http.request request # Net::HTTPResponse object

    case response
    when Net::HTTPOK then
      matches = response.body.scan /Connection: 0x([a-f0-9]+)\n\s+.+\s+.+\s+.+\s+remote: ([0-9\.]+).+\s+.+\s+.+\nuri (.+)\n.+\n.+out.size (\d+)\n.+\n.+\n.+\(([\d\.]+) seconds ago\)\nusername (.+)\ndelay_pool (\d+)/

      date = DateTime.parse(response['Date'])
      date = date.new_offset(DateTime.now.offset)

      matches.each do |match|

        match_url = match[2].match(/:\/\/([^\/]+).*/)
        match_url = match_url[1] unless match_url.nil?
        match_url = match[2].match(/[^:\/]*/)[0] if match_url.nil?

        data = {
            values: {
                data_down: match[3].to_i,
                duration: match[4].to_i,
                delay_pool: match[6].to_i
            },
            tags: {
                connection: match[0],
                ip: match[1],
                username: match[5],
                uri: match_url
            },
            timestamp: date.to_time.to_i
        }

        begin
          influxdb.write_point 'realtime', data, 's', 'realtime'
        rescue
          # ignored
        end

        # p '********************************************'
        # p "Connection: #{match[0]}"
        # p "IP: #{match[1]}"
        # p "URI: #{match[2]}"
        # p "Data Down: #{match[3]}"
        # p "Connection Duration: #{match[4]}"
        # p "Username: #{match[5]}"
        # p "Delay Pool: #{match[6]}"
        # p '********************************************'
      end
    else
      # type code here
    end
    #
    # p '********************************************'
    # p '********************************************'
    # p '********************************************'


    sleep 1

  end

end
