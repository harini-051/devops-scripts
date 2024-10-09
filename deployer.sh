#!/bin/bash

# Default environment (can be overridden with -e option)
ENV="staging"

# Action to take (build, deploy, monitor, logs, ec2-start, ec2-stop, ec2-status)
ACTION=""

# Service to manage (the name of your app, container, or EC2 instance)
SERVICE=""

# EC2 instance ID (for EC2-specific actions)
INSTANCE_ID=""

# Help function to display how to use the script
function show_help {
    echo "Usage: $0 [options] <service>"
    echo "Options:"
    echo "  -b, --build          Build and deploy a new Docker image"
    echo "  -d, --deploy         Deploy a pre-existing container"
    echo "  -m, --monitor        Monitor Docker container usage"
    echo "  -l, --logs           Fetch logs from the Docker container"
    echo "  -e, --env            Specify environment (default: staging)"
    echo "  -s, --ec2-start      Start an EC2 instance"
    echo "  -t, --ec2-stop       Stop an EC2 instance"
    echo "  -x, --ec2-status     Check EC2 instance status"
    echo "  -i, --instance-id    Specify EC2 instance ID (for EC2 actions)"
    echo "  -h, --help           Display this help message"
}

# Parse command-line options
while [[ $# -gt 0 ]]; do
    case $1 in
        -b|--build)
            ACTION="build"
            shift
            ;;
        -d|--deploy)
            ACTION="deploy"
            shift
            ;;
        -m|--monitor)
            ACTION="monitor"
            shift
            ;;
        -l|--logs)
            ACTION="logs"
            shift
            ;;
        -e|--env)
            ENV="$2"
            shift 2
            ;;
        -s|--ec2-start)
            ACTION="ec2-start"
            shift
            ;;
        -t|--ec2-stop)
            ACTION="ec2-stop"
            shift
            ;;
        -x|--ec2-status)
            ACTION="ec2-status"
            shift
            ;;
        -i|--instance-id)
            INSTANCE_ID="$2"
            shift 2
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            SERVICE="$1"
            shift
            ;;
    esac
done

# Make sure a service or instance ID is provided
if [[ -z "$SERVICE" && -z "$INSTANCE_ID" ]]; then
    echo "Error: No service or instance ID specified."
    show_help
    exit 1
fi

# Perform the requested action
case "$ACTION" in
    build)
        echo "Building and deploying $SERVICE in $ENV environment..."
        docker build -t "$SERVICE:$ENV" .  # Build the Docker image
        docker run -d --name "$SERVICE-$ENV" "$SERVICE:$ENV"  # Deploy (run) the container
        ;;
    deploy)
        echo "Deploying $SERVICE in $ENV environment..."
        docker run -d --name "$SERVICE-$ENV" "$SERVICE:$ENV"  # Just deploy the container
        ;;
    monitor)
        echo "Monitoring $SERVICE-$ENV container..."
        docker stats "$SERVICE-$ENV"  # Show CPU/memory usage
        ;;
    logs)
        echo "Fetching logs for $SERVICE-$ENV container..."
        docker logs "$SERVICE-$ENV"  # Show logs from the container
        ;;
    ec2-start)
        if [[ -z "$INSTANCE_ID" ]]; then
            echo "Error: EC2 instance ID is required."
            exit 1
        fi
        echo "Starting EC2 instance $INSTANCE_ID..."
        aws ec2 start-instances --instance-ids "$INSTANCE_ID"
        ;;
    ec2-stop)
        if [[ -z "$INSTANCE_ID" ]]; then
            echo "Error: EC2 instance ID is required."
            exit 1
        fi
        echo "Stopping EC2 instance $INSTANCE_ID..."
        aws ec2 stop-instances --instance-ids "$INSTANCE_ID"
        ;;
    ec2-status)
        if [[ -z "$INSTANCE_ID" ]]; then
            echo "Error: EC2 instance ID is required."
            exit 1
        fi
        echo "Checking status of EC2 instance $INSTANCE_ID..."
        aws ec2 describe-instance-status --instance-ids "$INSTANCE_ID"
        ;;
    *)
        echo "Invalid action."
        show_help
        ;;
esac
