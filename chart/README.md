# OpenCart Helm Chart

## Building the chart

```bash
cd manifests
helm package -u ../chart/opencart
```

## Create a release

```bash
replicated release create --yaml-dir manifests --promote Unstable
```

Images:
proxy.replicated.com/library/replicated-sdk-image:1.11.1
traefik:2.6.3
busybox:1.35
docker.io/library/mariadb:10.11
proxy.replicated.com/proxy/opencart-treefrog/923411875752.dkr.ecr.us-east-1.amazonaws.com/xav-test-php:latest
proxy.replicated.com/proxy/opencart-treefrog/923411875752.dkr.ecr.us-east-1.amazonaws.com/xav-test-apache:latest