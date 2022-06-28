# Foreman

Foreman Docker Contianer

Run with:

```shell
docker run -it -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run --name foreman.localdomain --hostname foreman.localdomain katello
```

After first start, you can relaunch with:

```shell
docker start foreman.localdomain
docker attach foreman.localdomain
```
