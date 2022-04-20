#!/usr/local/bin/python

import socket
import os
import enet
import random
import sys

tcp_socket_ip = '0.0.0.0'  
tcp_socket_port = int(os.environ.get('TCP_SOCKET_PORT'))
udp_socket_port=int(os.environ.get('UDP_SOCKET_PORT'))
udp_socket_ip=os.environ.get('UDP_SOCKET_IP').encode('utf-8')

udp_host=enet.Host(None, 1, 0, 0)
udp_addr=enet.Address(udp_socket_ip,udp_socket_port)

tcp_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
tcp_socket.bind((tcp_socket_ip,tcp_socket_port))
tcp_socket.listen(5)
while True:
  conn, addr = tcp_socket.accept()
  print('Connected by', addr)
  peer = udp_host.connect(udp_addr,1)
  if peer: 
    print("%s:" % peer)
    event = udp_host.service(1000)
    if event.type == enet.EVENT_TYPE_CONNECT:
       print("%s: CONNECT" % event.peer.address)
    else: 
      break
#    data = conn.recv(1024)
#    if not data:
#      break
#    print("%s" % data)
#    conn.sendall(data)
