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