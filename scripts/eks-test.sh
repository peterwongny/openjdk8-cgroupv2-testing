#!/bin/bash
# eks-test.sh - Script to run tests on EKS

# Create results directory if it doesn't exist
mkdir -p ../results

# Apply test manifests
echo "Applying test manifests to EKS cluster..."
kubectl apply -f ../kubernetes/k8s-test-jdk8u362.yaml
kubectl apply -f ../kubernetes/k8s-test-jdk8u372.yaml
kubectl apply -f ../kubernetes/k8s-test-jdk8u382.yaml
kubectl apply -f ../kubernetes/k8s-test-jdk8u362-explicit.yaml

# Wait for jobs to complete
echo "Waiting for jobs to complete..."
sleep 30

# Check job status
kubectl get jobs

# Collect logs
echo "Collecting logs from jobs..."
kubectl logs job/jdk8u362-cgroup-test > ../results/eks-jdk8u362.log
kubectl logs job/jdk8u372-cgroup-test > ../results/eks-jdk8u372.log
kubectl logs job/jdk8u382-cgroup-test > ../results/eks-jdk8u382.log
kubectl logs job/jdk8u362-cgroup-test-explicit > ../results/eks-jdk8u362-explicit.log

# Generate summary report
echo "Generating summary report..."
echo "# EKS Test Results Summary" > ../results/eks-summary.md
echo "" >> ../results/eks-summary.md
echo "| JDK Version | Detected CPUs | Detected Memory | Container Support |" >> ../results/eks-summary.md
echo "|------------|--------------|----------------|-------------------|" >> ../results/eks-summary.md

for version in "8u362" "8u372" "8u382"; do
  log_file="../results/eks-jdk${version}.log"
  if [ -f "$log_file" ]; then
    detected_cpus=$(grep "Available processors" "$log_file" | awk '{print $NF}')
    detected_memory=$(grep "Max memory" "$log_file" | awk '{print $3" MB"}')
    container_support="No"
    if grep -q "container" "$log_file"; then
      container_support="Yes"
    fi
    echo "| $version | $detected_cpus | $detected_memory | $container_support |" >> ../results/eks-summary.md
  fi
done

# Add explicit flags test
log_file="../results/eks-jdk8u362-explicit.log"
if [ -f "$log_file" ]; then
  detected_cpus=$(grep "Available processors" "$log_file" | awk '{print $NF}')
  detected_memory=$(grep "Max memory" "$log_file" | awk '{print $3" MB"}')
  container_support="No"
  if grep -q "container" "$log_file"; then
    container_support="Yes"
  fi
  echo "| 8u362 (explicit flags) | $detected_cpus | $detected_memory | $container_support |" >> ../results/eks-summary.md
fi

echo "EKS testing complete. Results saved to ../results/ directory."
