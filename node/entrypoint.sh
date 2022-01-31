#!/bin/bash

set -eo pipefail

CONFIGS_DIR='/etc/ton'
LOGS_DIR='/var/log/ton'
WORKING_DIR='/'
MAIN_TON_DEV_COMMIT=${MAIN_TON_DEV_COMMIT:-master}

mkdir -p "$CONFIGS_DIR" "$LOGS_DIR"

function configure() {
    DEFAULT_CONFIG_JSON=$(mktemp)
    jq --argjson cport "$CONSOLE_PORT" --arg ipaddr "$(printf '0.0.0.0:%u' "$ADNL_PORT")" \
        '.control_server_port = $cport | .ip_address = $ipaddr' \
        "$CONFIGS_DIR/default_config.json" > "$DEFAULT_CONFIG_JSON" \
        && mv "$DEFAULT_CONFIG_JSON" "$CONFIGS_DIR/default_config.json"

    curl -sS "https://raw.githubusercontent.com/tonlabs/main.ton.dev/$MAIN_TON_DEV_COMMIT/configs/ton-global.config.json" \
        -o "$CONFIGS_DIR/ton-global.config.json"
}

function run() {
    cd "$WORKING_DIR"

    ARGS=( '--configs' "$CONFIGS_DIR" )

    if [ ! -f "$CONFIGS_DIR/console_config.json" ]; then
        CONSOLE_KEY_INFO=$(mktemp)
        keygen > "$CONSOLE_KEY_INFO"

        CONSOLE_KEY=$(jq -r '{ type_id: 1209251014, pub_key: .public.pub_key }' "$CONSOLE_KEY_INFO")
        ton_node "${ARGS[@]}" --ckey "$CONSOLE_KEY" 2>&1 &

        TON_NODE_PID=$!

        while sleep 5s; do
            if [ -f "$CONFIGS_DIR/console_config.json" ]; then
                kill "$TON_NODE_PID" 2> /dev/null
                break
            fi
        done

        CONSOLE_CONFIG_JSON=$(mktemp)
        jq -s '.[0] as $k | .[1] | (.client_key = { type_id: 1209251014, pub_key: $k.public.pub_key })' \
            "$CONSOLE_KEY_INFO" \
            "$CONFIGS_DIR/console_config.json" > "$CONSOLE_CONFIG_JSON"
        mv "$CONSOLE_CONFIG_JSON" "$CONFIGS_DIR/console_config.json"
        SERVER_ADDR=$(printf '127.0.0.1:%u' "$CONSOLE_PORT")
        jq -s --arg addr "$SERVER_ADDR" '.[0] as $k | { config: .[1] | (.client_key = { type_id: 1209251014, pvt_key: $k.private.pvt_key }) | (.server_address = $addr) }' \
            "$CONSOLE_KEY_INFO" \
            "$CONFIGS_DIR/console_config.json" > "$CONFIGS_DIR/console.json"

        echo 'INFO: console configuration completed - restarting the node...'
        cat "$CONFIGS_DIR/console.json"
    fi

    exec ton_node "${ARGS[@]}" 2>&1
}

configure && run

