#!/bin/bash

############################################################################################
#Author: Harini
#Project: Docker Deployment Automation with EC2
#Usage: Automate the deployment of application using Docker and managing using EC2 instance
############################################################################################

#Debug Mode
#set -x

#Default Enviroment
ENV="staging"

#Action to take(build,deploy,monitor,logs,ec2-start,ec2-stop,ec2-status)
ACTION=""

#Service to manage
SERVICE=""

#EC2 instance ID
INSTANCE_ID=""

echo "Action: $ACTION"
echo "Service: $SERVICE"

set -x #debug mode

#Help function to how to use
function show_help {
    echo "Usage: ./deployer.sh [options] <service>"
    echo "Options:"
    echo "  -b, --build          Build and deploy a new Docker image"
    echo "  -d, --deploy         Deploy a pre-existing container"
    echo "  -m, --monitor        Monitor Docker container usage"
    echo "  -l, --logs           Fetch logs from the Docker container"
    echo "  -s, --ec2-start      Start an EC2 instance"
    echo "  -t, --ec2-stop       Stop an EC2 instance"
    echo "  -x, --ec2-status     Check EC2 instance status"
    echo "  -i, --instance-id    Specify EC2 instance ID (for EC2 actions)"
    echo "  -h, --help           Display this help message"
}

#Parse command line options
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

# Check if an action was specified
if [[ -z "$ACTION" ]]; then
    echo "No action specified."
    show_help
    exit 1
fi

# Check if a service was specified
if [[ -z "$SERVICE" ]]; then
    echo "No service specified."
    show_help
    exit 1
fi

echo "Action: $ACTION"
echo "Service: $SERVICE"

# Add your actions here
