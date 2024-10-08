#!/bin/bash

############################################################################################
#Author: Harini
#Project: Docker Deployment Automation with EC2
#Usage: Automate the deployment of application using Docker and managing using EC2 instance
############################################################################################

#Debug Mode
set -x

#Default Enviroment
ENV = "staging"

#Action to take(build,deploy,monitor,logs,ec2-start,ec2-stop,ec2-status)
ACTION = ""

#Service to manage
SERVICWE = ""

#EC2 instance ID
INSTANCE_ID = ""

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
while [[$# -gt 0]];do
	case $1 in
		-b|--build)
			ACTION = "build"
			shift
			;;
		-d|--deploy)
			ACTION = "deploy"
			shift
			;;
		-m|--monitor)
			ACTION = "monitor"
			shift
			;;
		-l|--logs)
			ACTION = "logs"
			shift
			;;
		-s|--ec2-start)
			ACTION = "ec2-start"
			shift
			;;
		-t|--ec2-stop)
			ACTION = "ec2-stop"
			shift
			;;
		-x|--ec2-status)
			ACTION = "ec2-status"
			shift
			;;
		-i|INSTANCE_ID)
			ISTANCE_ID = "$2"
			shift 2
			;;
		-h|--help)
			show_help
			Exit 0 
			;;
		)*
		SERVICE = "$1"
		shift
		;;
	esac
done

if[[-z "$SERVICE" && -z "$INSTANCE_ID" ]]
	echo "Error: No service or instance Id specified"
	show_help
	exit
fi

#Perform the requested Action
case "$ACTION" in
	build)
		echo "Building and deploying $SERVICE in $ENV enviroment..."
		docker build -t "$SERVICE:$ENV" . #Build the docker image
		docker run -d --name "$SERVICE-$ENV" "$SERVICE:$ENV" #Deploy and run the container
		;;
	deploy)
		echo "Deploying $SERVICE in $ENV environement..."
		docker run -d --name "$SERVICE-$ENV" "$SERVICE:$ENV" 
		;;
	monitor)
		echo "Monitor $SERVICE-$ENV container..."
		docker stats "$SERVICE-$ENV"
		;;
	logs)
		echo "Logs of $SERVICE-$ENV container... "
		docker logs "$SERVICE-$ENV"
		;;
	ec2-start)
		if[[-z "$INSTANCE_ID"]];then
			echo "Error: EC2 instance id is required"
			exit 0
		fi
		echo "Starting the ec2 instance $INSTANCE_ID..."
		aws ec2 start-instances --instance-ids i-"$INSTANCE_ID"
	ec2-stop)
		if[[-z $INSTANCE_ID]];then
			echo "Error: EC2 instance id is required"
			exit 0
		fi
		echo "Stopping the ec2 instance $INSTANCE_ID..."
		aws ec2 stop-instances --instance-ids i-"$INSTANCE_ID"
		;;
	ec2-status)
		if[[-z $INSTANCE_ID]];then
			echo "Error: EC2 instance id is required"
			exit 0
		fi
		echo "Checking status of ec2 instance $INSTANCE_ID..."
		aws ec2 describe-instance-status --instance-ids i-"$INSTANCE_ID"
		;;
	*)
		echo "INVALID ACTION"
		show_help
		;;
esac
		
			





