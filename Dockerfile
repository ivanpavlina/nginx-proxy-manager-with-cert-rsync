FROM jc21/nginx-proxy-manager:latest

RUN apt-get update && apt-get install -y rsync
RUN rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/services.d/cert-sync
COPY cert-sync.sh /etc/services.d/cert-sync/run
RUN chmod +x /etc/services.d/cert-sync/run
