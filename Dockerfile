FROM jc21/nginx-proxy-manager:latest

RUN apt-get update && apt-get install -y rsync
RUN rm -rf /var/lib/apt/lists/*

# Copy your script
COPY cert-sync.sh /usr/local/bin/cert-sync.sh
RUN chmod +x /usr/local/bin/cert-sync.sh

RUN mkdir -p /etc/services.d/cert-sync
RUN echo -e '#!/command/with-contenv bash\n\n/usr/local/bin/cert-sync.sh' > /etc/services.d/cert-sync/run
RUN chmod +x /etc/services.d/cert-sync/run
#RUN echo -e '#!/command/with-contenv bash\n\nsleep ${RSYNC_PERIOD:=-600}' > /etc/services.d/cert-sync/finish
#RUN chmod +x /etc/services.d/cert-sync/finish

#CMD ["/init"]