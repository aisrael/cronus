# Cronus is the Greek god of time
module Cronus
  VERSION = {{ `cat ./shard.yml|awk '/^version:/ {print $2}'`.stringify }}
end

require "./cronus/*"
