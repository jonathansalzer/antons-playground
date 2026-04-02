FROM nginx:alpine
COPY public/index.html /usr/share/nginx/html/index.html
RUN sed -i 's/listen       80;/listen       8080;/' /etc/nginx/conf.d/default.conf
EXPOSE 8080
