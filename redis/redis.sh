#!/bin/bash

/usr/lib/ruby/1.8/cosmoslot/redis/redis_6441/src/redis-server /usr/lib/ruby/1.8/cosmoslot/redis/conf/redis_6441.conf

sleep 1
echo 'redis_6441 ok'

/usr/lib/ruby/1.8/cosmoslot/redis/redis_6442/src/redis-server /usr/lib/ruby/1.8/cosmoslot/redis/conf/redis_6442.conf

sleep 1
echo 'redis_6442 ok'

/usr/lib/ruby/1.8/cosmoslot/redis/redis_6443/src/redis-server /usr/lib/ruby/1.8/cosmoslot/redis/conf/redis_6443.conf

sleep 1
echo 'redis_6443 ok'

/usr/lib/ruby/1.8/cosmoslot/redis/redis_6444/src/redis-server /usr/lib/ruby/1.8/cosmoslot/redis/conf/redis_6444.conf

sleep 1
echo 'redis_6444 ok'