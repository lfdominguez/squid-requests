Squid proxy live connections in ruby
====================================

This project is for people that need save into InfluxDB the information extracted from Squid active_requests action.

## Install InfluxDB gem dependency

```
gem install influxdb
```

## Create retention policy

```
CREATE DATABASE "squid" WITH DURATION 4w NAME "realtime"
```
