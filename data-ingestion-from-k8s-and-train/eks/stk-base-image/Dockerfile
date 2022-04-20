FROM python:3.9

RUN apt-get update -y
RUN apt-get install -y libcurl4
RUN apt-get install -y vim sqlite3 lsof tcpdump curl jq uuid default-jdk default-jre
RUN apt-get install -y libmcpp0
COPY . .
