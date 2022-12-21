FROM nginx:1.20.2-alpine
COPY index.html image.png /usr/share/nginx/html/
RUN rm /etc/nginx/conf.d/*
ADD diplom.conf /etc/nginx/conf.d/
