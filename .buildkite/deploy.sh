#!/usr/bin/env bash
set -ex

function usage() {
    echo "Usage:"
    echo ""
    echo "    ./deploy.sh -c <cluster_name> -s <service_name> -a <aws_account_number> -p <aws_profile>"
    echo ""
    echo "    -c, --cluster-name           ECS Cluster name"
    echo "    -s, --service-name           ECS Service name"
    echo "    -a, --aws-account-no         AWS account number"
    echo "    -p, --profile                AWS profile"
    echo "    -h, --help                   Help list"
    echo ""
}

while [ "$1" != "" ]; do
    case $1 in
        -c | --cluster-name )
            shift
            cluster_name=$1
            ;;
        -s | --service-name )
            shift
            service_name=$1
            ;;
        -a | --aws-account-no )
            shift
            aws_account_no=$1
            ;;
        -p | --profile )
            shift
            profile=$1
            ;;
        -h | --help )
            usage
            exit 1
            ;;
    esac
    shift
done

function init() {
    if [ -z "$cluster_name" ]; then
        echo "cluster-name argument is missing."
        exit 1
    fi

    if [ -z "$service_name" ]; then
        echo "service_name argument is missing."
        exit 1
    fi

    if [ -z "$aws_account_no" ]; then
        echo "$aws_account_no argument is missing."
        exit 1
    fi

    if [ -z "$profile" ]; then
        echo "profile argument is missing."
        exit 1
    fi

    dir=$(dirname "$0")

}

function deploy_ecs() {

    set -x
    # use buildkite commit hash as a TAG
    TAG=${BUILDKITE_COMMIT::6}

    echo "--- Deploying ${service_name} to ECS to ${cluser_name}"
    /usr/local/bin/ecs-deploy -c ${cluster_name} \
                              -n ${service_name} \
                              -i ${aws_account_no}.dkr.ecr.ap-southeast-1.amazonaws.com/nginx:${TAG} \
                              -p ${profile} --skip-deployments-check -t 240
}

init
deploy_ecs
