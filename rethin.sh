#!/bin/bash

thin stop -C /usr/local/ridemate/yml/thin_3400.yml
sleep 3
thin start -C /usr/local/ridemate/yml/thin_3400.yml
echo '3400 ok'

thin stop -C /usr/local/ridemate/yml/thin_3401.yml
sleep 3
thin start -C /usr/local/ridemate/yml/thin_3401.yml
echo '3401 ok'

thin stop -C /usr/local/ridemate/yml/thin_3402.yml
sleep 3
thin start -C /usr/local/ridemate/yml/thin_3402.yml
echo '3402 ok'

thin stop -C /usr/local/ridemate/yml/thin_3403.yml
sleep 3
thin start -C /usr/local/ridemate/yml/thin_3403.yml
echo '3403 ok'