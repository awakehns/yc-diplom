FROM nginx:1.27-alpine

ARG VERSION=dev
ENV APP_VERSION=${VERSION}

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

# Подставляем версию в HTML при сборке
RUN sed -i "s/__VERSION__/${VERSION}/g" /usr/share/nginx/html/index.html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
