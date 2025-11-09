## howard-chu-www

Development
```bash
sh dev.sh
```

Build the docker image and run it without using a daemon, when exitting, the image will be deleted
```bash
sh build-run.sh
```

Deployment
```bash
sh deploy.sh
```

Certificate generation using certbot
```bash
sudo certbot certonly --manual
```
Serve it with nginx to pass authentication.

Auto renewal
```bash
echo "0 0,12 * * * root /opt/certbot/bin/python -c 'import random; import time; time.sleep(random.random() * 3600)' && sudo certbot renew -q" | sudo tee -a /etc/crontab > /dev/null
```

To generate new certificates for the docker build, just build the docker container again, the updated certificates will be copied to it.

`assets` files are binary objects so they are ignored.