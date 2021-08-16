FROM nginx
RUN rm /etc/nginx/conf.d/default.conf
COPY /files/server.cer /etc/nginx/server.cer
COPY /files/server.key /etc/nginx/server.key
COPY /files/nginx.conf /etc/nginx/conf.d/default.conf