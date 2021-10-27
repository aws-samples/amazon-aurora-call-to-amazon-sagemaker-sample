FROM public.ecr.aws/p9d8y1e7/supertuxkart:latest
RUN apt install -y nginx
COPY server_config.xml /home/supertuxkart/stk-code/server_config.xml 
COPY start-server.sh /home/supertuxkart/stk-code/start-server.sh
