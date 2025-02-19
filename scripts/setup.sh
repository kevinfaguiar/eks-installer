#!/bin/bash -e

ls -la

CLUSTER_NAME="${CLUSTER_NAME:-terraform-eks-demo}"
CLUSTER_SIZE="${CLUSTER_SIZE:-1}"
CLUSTER_REGION="${CLUSTER_REGION:-us-west-2}"
CLUSTER_INSTANCE_TYPE="${CLUSTER_INSTANCE_TYPE:-m4.large}"
CLUSTER_KEY_NAME="${CLUSTER_KEY_NAME:-}"

echo forming dir

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR/../

echo $DIR

echo cded

ls -la

cd terraform/

echo will init

terraform init -refresh=false

echo initied

# try 3 times in case we are stuck waiting for EKS cluster to come up
set +e
N=0
SUCCESS="false"
until [ $N -ge 3 ]; do
  echo try
  terraform apply -auto-approve \
    -var "cluster-name=${CLUSTER_NAME}" \
    -var "cluster-size=${CLUSTER_SIZE}" \
    -var "cluster-region=${CLUSTER_REGION}" \
    -var "cluster-instance-type=${CLUSTER_INSTANCE_TYPE}" \
    -var "cluster-key-name=${CLUSTER_KEY_NAME}" \
    .
  if [[ "$?" == "0" ]]; then
    echo success
    SUCCESS="true"
    break
  fi
  N=$[$N+1]
  echo failed
done
set -e

if [[ "$SUCCESS" != "true" ]]; then
    exit 1
fi

terraform output kubeca > ../kubernetes/kubeca.txt
terraform output kubehost > ../kubernetes/kubehost.txt
terraform output kubeconfig > ../kubernetes/kubeconfig.yaml
terraform output config-map-aws-auth > ../kubernetes/config-map-aws-auth.yaml
