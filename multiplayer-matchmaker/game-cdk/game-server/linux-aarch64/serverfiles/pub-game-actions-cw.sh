#!/bin/bash -x
. /root/.bashrc
#based src/input/input.hpp - enum PlayerAction
#/root/.config/supertuxkart/config-0.10/stdout.log
game_stdout=$CLIENT_STDOUT
TEMPOUT_1=$(mktemp)
TEMPOUT_PA_ALL=$(mktemp)

while true
do
  psql -A -e -t -w -c "/*pub-game-actions-cw.sh*/update sessions set updated_at=NOW(),is_active=1 where id='$SESSION_ID';"
  echo "psql exit code="$?
  if (( $?>0 ))
  then
    echo "ERR-DB update sessions set updated_at=NOW()"
    exit 0
  fi
  if [[ $ENDPOINT != 'lobby' ]]
  then
    psql -A -e -t -w -c "/*pub-game-actions-cw.sh*/update server_sessions set updated_at=NOW() where id='$SERVER_SESSION_ID';"
    echo "psql exit code="$?
    if (( $?>0 ))
    then
      echo "ERR-DB update server_sessions set updated_at=NOW()"
      exit 0
    fi
  fi
  if [[ $ENDPOINT == 'lobby' ]]
  then
    sleep `echo $((10 + $RANDOM % 100))`
    psql -A -e -t -U postgres -w -c "update sessions set session_length=updated_at-created_at,is_active=0 where id='$SESSION_ID';"
    exit
  fi
  tail -$SIZE_OF_GAME_SAMPLE $game_stdout| grep "GameProtocol: Controller action"|grep -v dummyaddress| awk -F\; '{print $2}' > $TEMPOUT_1
  if [ -s $TEMPOUT_1 ]; then
    #getting the playeractions, the second field in GameProtocol: Controller action with ; as delimeter.
    is_session_started=1
    TEMPOUT_PA_ALL=$(mktemp)
    #add pod name to all pa events
    cat $TEMPOUT_1 | awk -v pod=$POD_NAME '{print pod"_"$1,$3}' | sort | uniq -c > $TEMPOUT_PA_ALL
    TEMPOUT_PA_STEER_LEFT=$(mktemp)
    cat $TEMPOUT_PA_ALL | awk '{if ($NF==0) print $2,$1}' > $TEMPOUT_PA_STEER_LEFT
    while read -r i; 
    do 
      pa_steer_left=`echo $i| awk '{print $2}'`
      client_id=`echo $i| awk '{print $1}'`
      client_ip=`echo $client_id| awk -F\_ '{print $2}' | awk -F\: '{print $1}'`
      aws cloudwatch put-metric-data --metric-name PA_STEER_LEFT --namespace ${CW_NS} --value $pa_steer_left --dimensions app=$APP
      aws cloudwatch put-metric-data --metric-name PA_STEER_LEFT --namespace ${CW_NS} --value $pa_steer_left --dimensions PLAYER_ACTIONS="PA_STEER_LEFT"
      id=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/insert into player_actions(created_at,action,value,client_id,client_ip) values (NOW(),'PA_STEER_LEFT','$pa_steer_left','$client_id','$client_ip') returning id;"`
      echo "psql exit code="$?
      if [ -z "$id" ]
      then
        echo "ERR-DB"
      fi
    done < $TEMPOUT_PA_STEER_LEFT

    TEMPOUT_PA_STEER_RIGHT=$(mktemp)
    cat $TEMPOUT_PA_ALL | awk '{if ($NF==1) print $2,$1}' > $TEMPOUT_PA_STEER_RIGHT
    while read -r i; 
    do 
      pa_steer_right=`echo $i| awk '{print $2}'`
      client_id=`echo $i| awk '{print $1}'`
      client_ip=`echo $client_id| awk -F\_ '{print $2}' | awk -F\: '{print $1}'`
      aws cloudwatch put-metric-data --metric-name PA_STEER_RIGHT --namespace ${CW_NS} --value $pa_steer_right --dimensions app=$APP
      aws cloudwatch put-metric-data --metric-name PA_STEER_RIGHT --namespace ${CW_NS} --value $pa_steer_right --dimensions PLAYER_ACTIONS="PA_STEER_RIGHT"
      id=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/insert into player_actions(created_at,action,value,client_id,client_ip) values (NOW(),'PA_STEER_RIGHT','$pa_steer_right','$client_id','$client_ip') returning id;"`
      echo "psql exit code="$?
      if [ -z "$id" ]
      then
        echo "ERR-DB"
      fi
    done < $TEMPOUT_PA_STEER_RIGHT

    TEMPOUT_PA_ACCEL=$(mktemp)
    cat $TEMPOUT_PA_ALL | awk '{if ($NF==2) print $2,$1}' > $TEMPOUT_PA_ACCEL
    while read -r i; 
    do 
      pa_accel=`echo $i| awk '{print $2}'`
      client_id=`echo $i| awk '{print $1}'`
      client_ip=`echo $client_id| awk -F\_ '{print $2}' | awk -F\: '{print $1}'`
      aws cloudwatch put-metric-data --metric-name PA_ACCEL --namespace ${CW_NS} --value $pa_accel --dimensions app=$APP
      aws cloudwatch put-metric-data --metric-name PA_ACCEL --namespace ${CW_NS} --value $pa_accel --dimensions PLAYER_ACTIONS="PA_ACCEL"
      id=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/insert into player_actions(created_at,action,value,client_id,client_ip) values (NOW(),'PA_ACCEL','$pa_accel','$client_id','$client_ip') returning id;"`
      echo "psql exit code="$?
      if [ -z "$id" ]
      then
        echo "ERR-DB"
      fi
    done < $TEMPOUT_PA_ACCEL

    TEMPOUT_PA_BRAKE=$(mktemp)
    cat $TEMPOUT_PA_ALL | awk '{if ($NF==3) print $2,$1}' > $TEMPOUT_PA_BRAKE
    while read -r i; 
    do 
      pa_brake=`echo $i| awk '{print $2}'`
      client_id=`echo $i| awk '{print $1}'`
      client_ip=`echo $client_id| awk -F\_ '{print $2}' | awk -F\: '{print $1}'`
      aws cloudwatch put-metric-data --metric-name PA_BRAKE --namespace ${CW_NS} --value $pa_brake --dimensions app=$APP
      aws cloudwatch put-metric-data --metric-name PA_BRAKE --namespace ${CW_NS} --value $pa_brake --dimensions PLAYER_ACTIONS="PA_BRAKE"
      id=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/insert into player_actions(created_at,action,value,client_id,client_ip) values (NOW(),'PA_BRAKE','$pa_brake','$client_id','$client_ip') returning id;"`
      echo "psql exit code="$?
      if [ -z "$id" ]
      then
        echo "ERR-DB"
      fi
    done < $TEMPOUT_PA_BRAKE

    TEMPOUT_PA_FIRE=$(mktemp)
    cat $TEMPOUT_PA_ALL | awk '{if ($NF==4) print $2,$1}' > $TEMPOUT_PA_FIRE
    while read -r i; 
    do 
      pa_fire=`echo $i| awk '{print $2}'`
      client_id=`echo $i| awk '{print $1}'`
      client_ip=`echo $client_id| awk -F\_ '{print $2}' | awk -F\: '{print $1}'`
      aws cloudwatch put-metric-data --metric-name PA_FIRE --namespace ${CW_NS} --value $pa_fire --dimensions app=$APP
      aws cloudwatch put-metric-data --metric-name PA_FIRE --namespace ${CW_NS} --value $pa_fire --dimensions PLAYER_ACTIONS="PA_FIRE"
      id=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/insert into player_actions(created_at,action,value,client_id,client_ip) values (NOW(),'PA_FIRE','$pa_fire','$client_id','$client_ip') returning id;"`
      echo "psql exit code="$?
      if [ -z "$id" ]
      then
        echo "ERR-DB"
      fi
    done < $TEMPOUT_PA_FIRE

    TEMPOUT_PA_LOOK_BACK=$(mktemp)
    cat $TEMPOUT_PA_ALL | awk '{if ($NF==5) print $2,$1}' > $TEMPOUT_PA_LOOK_BACK
    while read -r i; 
    do 
      pa_look_back=`echo $i| awk '{print $2}'`
      client_id=`echo $i| awk '{print $1}'`
      client_ip=`echo $client_id| awk -F\_ '{print $2}' | awk -F\: '{print $1}'`
      aws cloudwatch put-metric-data --metric-name PA_LOOK_BACK --namespace ${CW_NS} --value $pa_look_back --dimensions app=$APP
      aws cloudwatch put-metric-data --metric-name PA_LOOK_BACK --namespace ${CW_NS} --value $pa_look_back --dimensions PLAYER_ACTIONS="PA_LOOK_BACK"
      id=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/insert into player_actions(created_at,action,value,client_id,client_ip) values (NOW(),'PA_LOOK_BACK','$pa_look_back','$client_id','$client_ip') returning id;"`
      echo "psql exit code="$?
      if [ -z "$id" ]
      then
        echo "ERR-DB"
      fi
    done < $TEMPOUT_PA_LOOK_BACK
  else
    echo "no game actions yet"
    if [[ $is_session_started == 1 ]]
    then
      echo "session is over"
      exit 
    fi
  fi
  avg_session_length=`psql -A -q -t -w -c "/*pub-game-actions-cw.sh*/select avg(EXTRACT(MINUTE FROM session_length)) from sessions where app='$APP' and created_at<NOW()-'1 min'::INTERVAL and created_at>NOW()-'12 hour'::INTERVAL and session_length is not null;"|sed 's/ //g'`
  aws cloudwatch put-metric-data --metric-name AVG_SESSION_LENGTH --namespace ${CW_NS} --value $avg_session_length --dimensions app=$APP
  sleep $SLEEP_B4_PUT_CW
done
