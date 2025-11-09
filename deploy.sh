docker stop -t 1 homepage
docker rm homepage
docker build -t sberm/howard-chu-www .
# --restart unless-stopped: automatically starts after rebooting
docker run -p 80:80 -p 443:443 -d --restart unless-stopped --name homepage \
    -v /etc/letsencrypt:/etc/letsencrypt:ro \
    sberm/howard-chu-www