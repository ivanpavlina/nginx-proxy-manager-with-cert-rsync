FROM jc21/nginx-proxy-manager:latest

RUN apt-get update && apt-get install -y rsync cron
RUN rm -rf /var/lib/apt/lists/*

COPY cert-sync.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/cert-sync.sh

COPY cron-sync /etc/cron.d/cron-sync
RUN chmod 0644 /etc/cron.d/cron-sync

RUN crontab /etc/cron.d/cron-sync
RUN touch /var/log/cron.log

CMD /usr/local/bin/cert-sync.sh && cron && tail -f /var/log/cron.log