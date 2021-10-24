FROM 356566070122.dkr.ecr.us-west-2.amazonaws.com/supertuxkart:0.2
RUN apt-get --allow-releaseinfo-change update
RUN apt-get update -y
RUN apt-get install -y libcurl4
RUN apt-get install -y vim sqlite3 lsof tcpdump curl jq uuid default-jdk default-jre
RUN apt-get install -y python3 python3-pip
COPY server_config.xml /home/supertuxkart/stk-code/server_config.xml 
COPY stkservers.db /home/supertuxkart/stk-code/stkservers.db
COPY start-server.sh /home/supertuxkart/stk-code/start-server.sh
