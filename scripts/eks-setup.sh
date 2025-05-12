#!/bin/bash
# eks-setup.sh - Script to set up EKS cluster with AL2023 nodes

# Set variables
CLUSTER_NAME="test-jdk-cgroup"
REGION="us-west-2"
NODE_TYPE="t3.medium"
NODE_COUNT=2

# Create EKS cluster with AL2023 nodes
echo "Creating EKS cluster with Amazon Linux 2023 nodes..."
eksctl create cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --node-type $NODE_TYPE \
  --nodes $NODE_COUNT \
  --node-ami-family AmazonLinux2023

# Verify cluster is ready
echo "Verifying cluster is ready..."
kubectl get nodes

echo "EKS cluster setup complete."
