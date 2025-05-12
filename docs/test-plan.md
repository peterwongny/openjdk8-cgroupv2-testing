# OpenJDK 8 cgroup v2 Testing Plan

## Background

Amazon Linux 2023 uses cgroup v2 by default, while Amazon Linux 2 used cgroup v1. This change can affect how Java applications detect and respect container resource limits. According to documentation, OpenJDK 8u372 and newer should include support for cgroup v2.

## Test Objectives

1. Verify if the JVM correctly detects CPU limits in a cgroup v2 environment
2. Verify if the JVM correctly detects memory limits in a cgroup v2 environment
3. Compare behavior between different OpenJDK 8 versions (8u342, 8u362, 8u372, 8u382)

## Test Environments

1. **Local Docker Testing**
   - Test with Docker's cgroup v2 implementation
   - Apply CPU and memory constraints
   - Test multiple JDK versions

2. **EKS Testing with Amazon Linux 2023**
   - Deploy to EKS cluster with AL2023 nodes (cgroup v2)
   - Apply resource limits via Kubernetes
   - Test multiple JDK versions

## Test Methodology

### 1. Test Application

Create a Java application that reports:
- JVM version information
- Detected CPU resources via `Runtime.getRuntime().availableProcessors()`
- Detected memory resources via `Runtime.getRuntime().maxMemory()`
- Container-related system properties and JVM flags

### 2. Docker Testing

- Build Docker images with different JDK versions
- Run containers with explicit CPU and memory limits
- Test with default JVM settings
- Test with explicit container support flags

### 3. EKS Testing

- Create EKS cluster with Amazon Linux 2023 nodes
- Deploy test pods with resource limits
- Compare resource detection across JDK versions

### 4. Analysis Criteria

For each test, verify:
1. **CPU Detection**: Does `availableProcessors()` return the container limit?
2. **Memory Detection**: Does `maxMemory()` respect the container memory limit?
3. **JVM Flags**: Are container-aware flags automatically set?

## Expected Results

- JDK versions before 8u372 may not correctly detect cgroup v2 limits
- JDK 8u372 and newer should correctly detect cgroup v2 limits
- Explicit JVM flags may enable container awareness in older versions

## Test Execution

1. Run Docker tests using `scripts/test-jdk-cgroup.sh`
2. Run Docker tests with explicit flags using `scripts/test-jdk-cgroup-explicit.sh`
3. Set up EKS cluster using `scripts/eks-setup.sh`
4. Run EKS tests using `scripts/eks-test.sh`
5. Analyze results and document findings
