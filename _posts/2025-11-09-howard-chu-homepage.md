---
layout: post
title: "Automating the Howard Chu Homepage"
excerpt_separator: <!-- truncate -->
---
This is done via `github webhook` and `systemd`. When github receives a push (likely from local branch), it notifies the remote server that it should pull. The remote server pulls from github, and runs `docker build` to build the website, and serves it with `nginx`.

The auto-build program is a `Flask` script managed by `systemd`, setup by generating a `systemd` service file using the `auto-build-setup.sh` shell script.

```
service="[Unit]
Description=howard-chu-www auto build daemon

[Service]
Type=simple
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/.venv/bin/flask run --host 0.0.0.0 --port 5000
Restart=on-failure
RestartSec=3
KillSignal=SIGKILL
Environment="FLASK_ENV=production"
Environment="PYTHONUNBUFFERED=1"


[Install]
WantedBy=multi-user.target"

echo "$service" > /etc/systemd/system/howard-chu-www.service
sudo systemctl daemon-reload
sudo systemctl enable howard-chu-www
sudo systemctl start howard-chu-www
```

<!-- truncate -->

Now I don't need to worry about the remote server, if it builds on my local machine, after pushing to github, it will be served on my server.

The Howard Chu Homepage project has been open sourced on [https://github.com/Sberm/howard-chu-www](https://github.com/Sberm/howard-chu-www.git)

{% include comment_section.html %}
