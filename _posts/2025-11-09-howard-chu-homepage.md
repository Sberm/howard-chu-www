---
layout: post
title: "Automating Howard Chu Homepage"
---

This is done via `github webhook` and `systemd`. When github receives a push (likely from local branch), it notifies the remote server that it should pull. The remote server pulls from github, and runs `docker build` to build the website, and serve it with `nginx`.

The auto-build program is a `Flask` script managed by `systemd`, setup by generating a `systemd` service file using `auto-build-setup.sh` shell script.
