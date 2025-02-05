FROM telicent/telicent-nginx1.27:latest
COPY conf/ /usr/local/nginx/conf/
COPY index.html /usr/local/nginx/html/

EXPOSE 8080

# Run NGINX in the foreground (rootless mode as configured)
CMD ["/usr/sbin/nginx", "-g", "daemon off;"]

# Default logs are located under
# /usr/local/nginx/logs/access.log
# /usr/local/nginx/logs/error.log
# the image links stdour stderr to /var/log/nginx/access.log errr.log
# make sure to update point your configs to these files if you want to see logs in docker