# OpenJDK 8 cgroup v2 Testing

This repository contains tests to verify OpenJDK 8's compatibility with cgroup v2, specifically focusing on resource limit detection in containerized environments.

## Background

Amazon Linux 2023 uses cgroup v2 by default, while Amazon Linux 2 used cgroup v1. This change can affect how Java applications detect and respect container resource limits.

According to documentation, OpenJDK 8u372 and newer should include support for cgroup v2.

## Test Results Summary

Our tests confirm that:

1. **JDK 8u372 is the turning point**: OpenJDK 8u372 and newer correctly detect container resource limits in cgroup v2 environments.
2. **JDK 8u362 and older**: These versions do not detect cgroup v2 limits correctly and instead report host system resources.

### Docker Test Results

| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |
|------------|-----------|-------------|--------------|----------------|-------------------|
| 8u342/8u362 | Any | Any | 8 (host CPUs) | 1.7 GB (host memory) | No |
| 8u372/8u382 | 0.5/1 | 256m/512m | 1 | ~123 MB | Yes |
| 8u372/8u382 | 2 | 1g | 2 | ~247 MB | Yes |

**Note on Container Support**: While JDK 8u372+ correctly detects container limits (marked as "Yes" above), none of the tested JDK versions expose explicit container-related system properties through the standard Java API. The "Container Support" column indicates whether the JVM correctly respects container limits, not whether it exposes container-specific properties.

For example:
- In JDK 8u372+, `Runtime.getRuntime().availableProcessors()` correctly returns the container's CPU limit (e.g., 1 CPU when limited to 1 CPU)
- In JDK 8u362 and earlier, the same method incorrectly returns the host's CPU count (e.g., 8 CPUs even when limited to 1 CPU)
- However, even in JDK 8u372+, there are no properties like `java.container.cpu` or `java.container.memory` that applications can query via `System.getProperties()` to explicitly determine container limits
- This means applications can indirectly benefit from container awareness (proper thread pool sizing, memory management) but cannot directly query "am I in a container?" or "what are my container limits?"

For detailed findings, see [results/findings.md](results/findings.md).

## Repository Structure

```
.
├── README.md                     # This file
├── AmazonQ.md                    # Test documentation
├── Dockerfile.jdk8               # Dockerfile for test images
├── docs/                         # Documentation
│   ├── test-plan.md              # Detailed test plan
│   └── findings-template.md      # Template for recording findings
├── kubernetes/                   # Kubernetes manifests
│   ├── k8s-test-jdk8u362.yaml    # Test job for JDK 8u362
│   ├── k8s-test-jdk8u372.yaml    # Test job for JDK 8u372
│   ├── k8s-test-jdk8u382.yaml    # Test job for JDK 8u382
│   └── k8s-test-jdk8u362-explicit.yaml # Test with explicit flags
├── results/                      # Test results
│   ├── docker-summary.md         # Docker test summary
│   ├── docker-explicit-summary.md # Docker test with explicit flags summary
│   ├── simulated-eks-summary.md  # Simulated EKS test summary
│   └── findings.md               # Comprehensive findings
├── scripts/                      # Test scripts
│   ├── test-jdk-cgroup.sh        # Docker test script
│   ├── test-jdk-cgroup-explicit.sh # Docker test with explicit flags
│   ├── eks-setup.sh              # EKS cluster setup script
│   ├── eks-test.sh               # EKS test script
│   └── simulate-eks-test.sh      # Simulated EKS test script
└── src/                          # Source code
    └── ResourceDetectionTest.java # Test application
```

## How to Run Tests

### Local Docker Testing

```bash
# Make scripts executable
chmod +x scripts/*.sh

# Run Docker tests
cd scripts
./test-jdk-cgroup.sh

# Run Docker tests with explicit flags
./test-jdk-cgroup-explicit.sh

# Run simulated EKS tests
./simulate-eks-test.sh
```

## Recommendations

1. **For Amazon Linux 2023 (which uses cgroup v2)**: Use OpenJDK 8u372 or newer to ensure your Java applications correctly detect and respect container resource limits.

2. **For applications using older JDK versions**: If you must use JDK 8u362 or older with Amazon Linux 2023, be aware that your Java applications will see the host's resources rather than container limits.

3. **Migration strategy**: When migrating from Amazon Linux 2 to Amazon Linux 2023, prioritize upgrading to at least OpenJDK 8u372 to ensure proper container resource detection.
