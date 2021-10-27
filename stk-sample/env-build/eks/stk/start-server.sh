#!/bin/bash

trap sighandler TERM QUIT EXIT KILL

sighandler () {
  echo -en "\n## Caught SIGTERM\n";
  echo -en "\n## deregister game-server $game_server_endpoint $game_server_id \n";
  exit $?
}
sleep 1

if [ -z ${GAME_MODE+x} ];
then
  GAME_MODE=0
fi
service nginx start
./cmake_build/bin/supertuxkart --server-config=/home/supertuxkart/stk-code/server_config.xml --log=0 --connection-debug --mode=${GAME_MODE} 
