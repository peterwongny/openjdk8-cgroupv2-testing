#!/bin/bash
# simulate-eks-test.sh - Script to simulate EKS tests using Docker

# Create results directory if it doesn't exist
mkdir -p ../results

# Function to run a test with a specific JDK version
function run_test() {
  jdk_version=$1
  
  echo "===================================================="
  echo "Testing JDK $jdk_version in simulated Kubernetes environment"
  echo "===================================================="
  
  # Create a container with resource limits similar to Kubernetes pod
  docker run --rm \
    --cpus=1 \
    --memory=512m \
    --name jdk-k8s-test-$jdk_version \
    jdk-cgroup-test:$jdk_version | tee ../results/simulated-eks-$jdk_version.log
  
  echo ""
}

# Function to run a test with explicit flags
function run_test_explicit() {
  jdk_version=$1
  
  echo "===================================================="
  echo "Testing JDK $jdk_version with explicit flags in simulated Kubernetes environment"
  echo "===================================================="
  
  # Create a container with resource limits and explicit JVM flags
  docker run --rm \
    --cpus=1 \
    --memory=512m \
    --name jdk-k8s-test-explicit-$jdk_version \
    jdk-cgroup-test:$jdk_version \
    -XX:+UseContainerSupport \
    -XX:+PreferContainerQuotaForCPUCount \
    -XX:ParallelGCThreads=2 \
    -XX:ConcGCThreads=2 \
    -XX:MaxRAMPercentage=75.0 | tee ../results/simulated-eks-explicit-$jdk_version.log
  
  echo ""
}

# Run tests for each JDK version
for version in "8u362" "8u372" "8u382"; do
  run_test $version
done

# Run tests with explicit flags
for version in "8u362" "8u372"; do
  run_test_explicit $version
done

# Generate summary report
echo "Generating summary report..."
echo "# Simulated EKS Test Results Summary" > ../results/simulated-eks-summary.md
echo "" >> ../results/simulated-eks-summary.md
echo "| JDK Version | Detected CPUs | Detected Memory | Container Support |" >> ../results/simulated-eks-summary.md
echo "|------------|--------------|----------------|-------------------|" >> ../results/simulated-eks-summary.md

for version in "8u362" "8u372" "8u382"; do
  log_file="../results/simulated-eks-$version.log"
  if [ -f "$log_file" ]; then
    detected_cpus=$(grep "Available processors" "$log_file" | awk '{print $NF}')
    detected_memory=$(grep "Max memory" "$log_file" | awk '{print $3" "$4}')
    container_support="No"
    if grep -q "container" "$log_file"; then
      container_support="Yes"
    fi
    echo "| $version | $detected_cpus | $detected_memory | $container_support |" >> ../results/simulated-eks-summary.md
  fi
done

# Add explicit flags test results
echo "" >> ../results/simulated-eks-summary.md
echo "## With Explicit Container Support Flags" >> ../results/simulated-eks-summary.md
echo "" >> ../results/simulated-eks-summary.md
echo "| JDK Version | Detected CPUs | Detected Memory | Container Support |" >> ../results/simulated-eks-summary.md
echo "|------------|--------------|----------------|-------------------|" >> ../results/simulated-eks-summary.md

for version in "8u362" "8u372"; do
  log_file="../results/simulated-eks-explicit-$version.log"
  if [ -f "$log_file" ]; then
    detected_cpus=$(grep "Available processors" "$log_file" | awk '{print $NF}')
    detected_memory=$(grep "Max memory" "$log_file" | awk '{print $3" "$4}')
    container_support="No"
    if grep -q "container" "$log_file"; then
      container_support="Yes"
    fi
    echo "| $version (explicit flags) | $detected_cpus | $detected_memory | $container_support |" >> ../results/simulated-eks-summary.md
  fi
done

echo "Simulated EKS testing complete. Results saved to ../results/ directory."
