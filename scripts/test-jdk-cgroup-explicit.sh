#!/bin/bash
# test-jdk-cgroup-explicit.sh - Test with explicit JVM flags

# JDK versions to test
JDK_VERSIONS=("8u342" "8u362" "8u372" "8u382")

# Create results directory if it doesn't exist
mkdir -p ../results

# Test with explicit JVM flags
function run_test_with_flags() {
  jdk_version=$1
  cpu_limit=$2
  memory_limit=$3
  
  echo "===================================================="
  echo "Testing JDK $jdk_version with CPU=$cpu_limit, Memory=$memory_limit (explicit flags)"
  echo "===================================================="
  
  docker run --rm \
    --cpus=$cpu_limit \
    --memory=$memory_limit \
    jdk-cgroup-test:$jdk_version \
    -XX:+UseContainerSupport \
    -XX:+PreferContainerQuotaForCPUCount \
    -XX:ParallelGCThreads=2 \
    -XX:ConcGCThreads=2 \
    -XX:MaxRAMPercentage=75.0 | tee ../results/docker-explicit-$jdk_version-${cpu_limit}c-${memory_limit}.log
  
  echo ""
}

# Run tests with various resource configurations and explicit flags
for version in "${JDK_VERSIONS[@]}"; do
  run_test_with_flags $version 1 512m
done

# Generate summary report for explicit flag tests
echo "Generating summary report for explicit flag tests..."
echo "# Docker Test Results with Explicit Flags Summary" > ../results/docker-explicit-summary.md
echo "" >> ../results/docker-explicit-summary.md
echo "| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |" >> ../results/docker-explicit-summary.md
echo "|------------|-----------|-------------|--------------|----------------|-------------------|" >> ../results/docker-explicit-summary.md

for version in "${JDK_VERSIONS[@]}"; do
  log_file="../results/docker-explicit-$version-1c-512m.log"
  if [ -f "$log_file" ]; then
    detected_cpus=$(grep "Available processors" "$log_file" | awk '{print $NF}')
    detected_memory=$(grep "Max memory" "$log_file" | awk '{print $3" "$4}')
    container_support="No"
    if grep -q "container" "$log_file"; then
      container_support="Yes"
    fi
    echo "| $version | 1 | 512m | $detected_cpus | $detected_memory | $container_support |" >> ../results/docker-explicit-summary.md
  fi
done

echo "Testing with explicit flags complete. Results saved to ../results/ directory."
