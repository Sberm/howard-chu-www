docker build -t sberm/howard-chu-www .
docker run -p 80:80 -p 443:443 -it --rm --name homepage \
    -v /etc/letsencrypt:/etc/letsencrypt:ro \
    sberm/howard-chu-www bash