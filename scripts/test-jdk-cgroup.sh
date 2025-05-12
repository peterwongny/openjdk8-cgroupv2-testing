#!/bin/bash
# test-jdk-cgroup.sh - Script to test JDK cgroup v2 compatibility

# JDK versions to test
JDK_VERSIONS=("8u342" "8u362" "8u372" "8u382")

# Create results directory if it doesn't exist
mkdir -p ../results

# Build test images for each JDK version
for version in "${JDK_VERSIONS[@]}"; do
  echo "Building test image for JDK $version"
  docker build --build-arg JDK_VERSION=$version -t jdk-cgroup-test:$version -f ../Dockerfile.jdk8 ..
done

# Test with different resource limits
function run_test() {
  jdk_version=$1
  cpu_limit=$2
  memory_limit=$3
  
  echo "===================================================="
  echo "Testing JDK $jdk_version with CPU=$cpu_limit, Memory=$memory_limit"
  echo "===================================================="
  
  docker run --rm \
    --cpus=$cpu_limit \
    --memory=$memory_limit \
    jdk-cgroup-test:$jdk_version | tee ../results/docker-$jdk_version-${cpu_limit}c-${memory_limit}.log
  
  echo ""
}

# Run tests with various resource configurations
for version in "${JDK_VERSIONS[@]}"; do
  run_test $version 0.5 256m
  run_test $version 1 512m
  run_test $version 2 1g
done

# Generate summary report
echo "Generating summary report..."
echo "# Docker Test Results Summary" > ../results/docker-summary.md
echo "" >> ../results/docker-summary.md
echo "| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |" >> ../results/docker-summary.md
echo "|------------|-----------|-------------|--------------|----------------|-------------------|" >> ../results/docker-summary.md

for version in "${JDK_VERSIONS[@]}"; do
  for cpu in 0.5 1 2; do
    for mem in 256m 512m 1g; do
      log_file="../results/docker-$version-${cpu}c-${mem}.log"
      if [ -f "$log_file" ]; then
        detected_cpus=$(grep "Available processors" "$log_file" | awk '{print $NF}')
        detected_memory=$(grep "Max memory" "$log_file" | awk '{print $3" "$4}')
        container_support="No"
        if grep -q "container" "$log_file"; then
          container_support="Yes"
        fi
        echo "| $version | $cpu | $mem | $detected_cpus | $detected_memory | $container_support |" >> ../results/docker-summary.md
      fi
    done
  done
done

echo "Testing complete. Results saved to ../results/ directory."
