#!/command/with-contenv /bin/bash

# Check if required environment variables are set
errored=false
REQUIRED_VARS=("SOURCE_CERT_DIR_PATH" "DEST_CERT_DIR_PATH" "SSH_KEY_PATH" "SSH_USER" "SSH_HOST")
for var in "${REQUIRED_VARS[@]}"; do
    if [ -z "${!var}" ]; then
        echo "[CERT_SYNC] Error: Environment variable $var is not set"
        errored=true
    fi
done

if [ "$errored" = true ]; then
    echo "[CERT_SYNC] environment check failed. Full env:"
    printenv
    exit 1
fi


PREV_CHECKSUM_FILE="/previous_cert_checksum"

/usr/bin/rsync -avzqL -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH" "${SSH_USER}@${SSH_HOST}:${SOURCE_CERT_DIR_PATH}/fullchain.pem" "$DEST_CERT_DIR_PATH"
/usr/bin/rsync -avzqL -e "ssh -o StrictHostKeyChecking=no -i $SSH_KEY_PATH" "${SSH_USER}@${SSH_HOST}:${SOURCE_CERT_DIR_PATH}/privkey.pem" "$DEST_CERT_DIR_PATH"

chmod 644 "$DEST_CERT_DIR_PATH/fullchain.pem" "$DEST_CERT_DIR_PATH/privkey.pem"

CURRENT_CHECKSUM=$(/usr/bin/sha256sum "$DEST_CERT_DIR_PATH/fullchain.pem" "$DEST_CERT_DIR_PATH/privkey.pem")

if [ ! -f "$PREV_CHECKSUM_FILE" ] || [ "$CURRENT_CHECKSUM" != "$(cat $PREV_CHECKSUM_FILE)" ]; then
    echo "[CERT_SYNC] Reloading nginx due to certificate modification"
    /usr/sbin/nginx -s reload
    echo "$CURRENT_CHECKSUM" > "$PREV_CHECKSUM_FILE"
else
    echo "[CERT_SYNC] No changes detected, everything is up-to-date."
fi

sleep ${RSYNC_PERIOD:=-600}