BUILD_TIME := "$(date +'%Y%m%d-%H%M%S')"
BINARY_NAME := "d-prod"
BACKUP_BINARY_NAME := "d-prod-backup"
BUILD_DIR := "./backend-go"
REMOTE_USER := "ubuntu"
REMOTE_HOST := "api.iith.dev"
REMOTE_PATH := "/home/ubuntu/backend"
TMUX_SESSION := "backend"

export-env:
    scp -r {{BUILD_DIR}}/.env {{REMOTE_USER}}@{{REMOTE_HOST}}:{{REMOTE_PATH}}
    @echo "Exporting environment variables..."
    ssh {{REMOTE_USER}}@{{REMOTE_HOST}} "\
        set -o allexport && \
        source {{REMOTE_PATH}}/.env && \
        set +o allexport"
    @echo "Environment variables exported."

build-backend:
    @echo "Building backend binary..."
    cd backend-go && \
    export BUILD_TIME="{{BUILD_TIME}}" && \
    GOOS=linux GOARCH=amd64 go build -ldflags "-X 'main.buildTime={{BUILD_TIME}}'" -o "{{BINARY_NAME}}" main.go
    @echo "Backend build complete: {{BUILD_DIR}}/{{BINARY_NAME}}"

create-service: build-backend push-templates
    echo "[Unit]" > {{BINARY_NAME}}.service
    echo "Description=Backend application for IITH Dashboard" >> {{BINARY_NAME}}.service
    echo "After=network.target" >> {{BINARY_NAME}}.service
    echo "" >> {{BINARY_NAME}}.service
    echo "[Service]" >> {{BINARY_NAME}}.service
    echo "User={{REMOTE_USER}}" >> {{BINARY_NAME}}.service
    echo "ExecStart=/usr/local/bin/{{BINARY_NAME}}" >> {{BINARY_NAME}}.service
    echo "Restart=always" >> {{BINARY_NAME}}.service
    echo "WorkingDirectory={{REMOTE_PATH}}" >> {{BINARY_NAME}}.service
    echo "EnvironmentFile={{REMOTE_PATH}}/.env" >> {{BINARY_NAME}}.service
    echo "" >> {{BINARY_NAME}}.service
    echo "[Install]" >> {{BINARY_NAME}}.service
    echo "WantedBy=multi-user.target" >> {{BINARY_NAME}}.service
    scp {{BINARY_NAME}}.service {{REMOTE_USER}}@{{REMOTE_HOST}}:/tmp/{{BINARY_NAME}}.service
    # ssh {{REMOTE_USER}}@{{REMOTE_HOST}} << 'EOF'
    #     sudo mv {{REMOTE_PATH}}/tmp/{{BINARY_NAME}}.service /etc/systemd/system/{{BINARY_NAME}}.service
    #   sudo systemctl daemon-reload

    #   sudo systemctl enable {{BINARY_NAME}}
    #   sudo systemctl restart {{BINARY_NAME}}
    # EOF

    # ssh {{REMOTE_USER}}@{{REMOTE_HOST}} "systemctl daemon-reload && systemctl enable {{BINARY_NAME}}.service"

deploy: export-env create-service init-tables
    scp -r {{BUILD_DIR}}/{{BINARY_NAME}} {{REMOTE_USER}}@{{REMOTE_HOST}}:{{REMOTE_PATH}}
    ssh {{REMOTE_USER}}@{{REMOTE_HOST}} "\
        sudo mv {{REMOTE_PATH}}/{{BINARY_NAME}} /usr/local/bin/{{BINARY_NAME}} && \
        sudo chmod +x /usr/local/bin/{{BINARY_NAME}} && \
        sudo mv /tmp/{{BINARY_NAME}}.service /etc/systemd/system/ && \
        sudo systemctl daemon-reload && \
        sudo systemctl enable {{BINARY_NAME}} && \
        sudo systemctl restart {{BINARY_NAME}}"

deploy2:
    @echo "Deploying backend to {{REMOTE_HOST}}..."
    cd backend && \
    GOOS=linux GOARCH=amd64 go build -ldflags "-X 'main.buildTime={{BUILD_TIME}}'" -o "{{BINARY_NAME}}" main.go
    ssh {{REMOTE_USER}}@{{REMOTE_HOST}} "mv {{REMOTE_PATH}}/{{BINARY_NAME}} {{REMOTE_PATH}}/{{BACKUP_BINARY_NAME}}"
    scp -r {{BUILD_DIR}}/{{BINARY_NAME}} {{REMOTE_USER}}@{{REMOTE_HOST}}:{{REMOTE_PATH}}

    # ssh {{REMOTE_USER}}@{{REMOTE_HOST}} "tmux send-keys -t {{TMUX_SESSION}} C-c; sleep 1; tmux send-keys -t {{TMUX_SESSION}} './{{BINARY_NAME}}' C-m"

push-templates:
    @echo "Pushing templates to {{REMOTE_HOST}}..."
    scp -r {{BUILD_DIR}}/internal/templates {{REMOTE_USER}}@{{REMOTE_HOST}}:{{REMOTE_PATH}}/internal
    @echo "Templates pushed."

init-tables:
    @echo "Initializing tables..."
    scp -r {{BUILD_DIR}}/sql/init.sql {{REMOTE_USER}}@{{REMOTE_HOST}}:{{REMOTE_PATH}}
    ssh {{REMOTE_USER}}@{{REMOTE_HOST}} "cd {{REMOTE_PATH}} && export PGPASSWORD=postgres && psql -U postgres -d dashboard-stage -h localhost -p 5432 -f init.sql"
    @echo "Tables initialized."

build:
    GOOS=linux GOARCH=amd64 go build -o bin/app-linux

fmt:
    go fmt ./...
    golangci-lint run

run:
    go run main.go

help:
    just -l
