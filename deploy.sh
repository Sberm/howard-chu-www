set -e
docker stop -t 1 homepage || true
docker rm homepage || true
docker build -t sberm/howard-chu-www .
docker run -p 80:80 -p 443:443 -d --restart unless-stopped --name homepage \
    -v /etc/letsencrypt:/etc/letsencrypt:ro \
    sberm/howard-chu-www