## howard-chu-www

Development
```bash
# install gem, jekyll and bundler, and run bundle
# sudo dnf install ruby ruby-devel openssl-devel redhat-rpm-config gcc-c++ @development-tools
# gem install jekyll bundler
# bundle
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

`assets` files are binary objects so they are ignored in git, put required files into it manually to make posts look okay.

Automatic rebuild (using systemd for daemon management)
```
python3 -m venv .venv
pip install -r requirements.txt
sh auto-build-setup.sh
```
A service file `/etc/systemd/system/howard-chu-www.service` will be written, use `sudo systemctl stop howard-chu-www` to stop it, and `sudo systemctl status howard-chu-www` to check the running status.

Run auto-build for development
```
.venv/bin/flask run --host 0.0.0.0 --port 5000
```

Put the resume in `assets` and name it to the according file name.
