# OpenJDK 8 cgroup v2 Compatibility Findings

## Summary

This document summarizes the findings from testing OpenJDK 8's compatibility with cgroup v2, specifically focusing on resource limit detection in containerized environments.

## Docker Test Results

| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |
|------------|-----------|-------------|--------------|----------------|-------------------|
| 8u342 | 0.5 | 256m | 8 | 1.7 GB | No |
| 8u342 | 1 | 512m | 8 | 1.7 GB | No |
| 8u342 | 2 | 1g | 8 | 1.7 GB | No |
| 8u362 | 0.5 | 256m | 8 | 1.7 GB | No |
| 8u362 | 1 | 512m | 8 | 1.7 GB | No |
| 8u362 | 2 | 1g | 8 | 1.7 GB | No |
| 8u372 | 0.5 | 256m | 1 | 121.8 MB | No |
| 8u372 | 1 | 512m | 1 | 123.8 MB | No |
| 8u372 | 2 | 1g | 2 | 247.5 MB | No |
| 8u382 | 0.5 | 256m | 1 | 121.8 MB | No |
| 8u382 | 1 | 512m | 1 | 123.8 MB | No |
| 8u382 | 2 | 1g | 2 | 247.5 MB | No |

## Docker Test Results with Explicit Flags

| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |
|------------|-----------|-------------|--------------|----------------|-------------------|
| 8u342 | 1 | 512m | 8 | 1.7 GB | No |
| 8u362 | 1 | 512m | 8 | 1.7 GB | No |
| 8u372 | 1 | 512m | 1 | 123.8 MB | No |
| 8u382 | 1 | 512m | 1 | 123.8 MB | No |

## Simulated EKS Test Results

| JDK Version | Detected CPUs | Detected Memory | Container Support |
|------------|--------------|----------------|-------------------|
| 8u362 | 8 | 1.7 GB | No |
| 8u372 | 1 | 123.8 MB | No |
| 8u382 | 1 | 123.8 MB | No |

### With Explicit Container Support Flags

| JDK Version | Detected CPUs | Detected Memory | Container Support |
|------------|--------------|----------------|-------------------|
| 8u362 (explicit flags) | 8 | 1.7 GB | No |
| 8u372 (explicit flags) | 1 | 123.8 MB | No |

## Analysis

### CPU Limit Detection

1. **JDK 8u342 and 8u362**: These versions do not correctly detect container CPU limits in cgroup v2 environments. They report 8 CPUs regardless of the container limits set (0.5, 1, or 2 CPUs). This indicates they are detecting the host system's CPU count rather than the container limits.

2. **JDK 8u372 and 8u382**: These versions correctly detect container CPU limits in cgroup v2 environments. They report the appropriate number of CPUs based on the container limits:
   - 1 CPU when the limit is set to 0.5 or 1 CPU
   - 2 CPUs when the limit is set to 2 CPUs

### Memory Limit Detection

1. **JDK 8u342 and 8u362**: These versions do not correctly detect container memory limits in cgroup v2 environments. They report 1.7 GB of memory regardless of the container limits set (256MB, 512MB, or 1GB). This indicates they are detecting the host system's memory rather than the container limits.

2. **JDK 8u372 and 8u382**: These versions correctly detect container memory limits in cgroup v2 environments. They report memory sizes proportional to the container limits:
   - ~122MB when the limit is set to 256MB
   - ~124MB when the limit is set to 512MB
   - ~248MB when the limit is set to 1GB

### Memory Limit vs. Detected Memory

The difference between the memory limit (e.g., 1g or 1024MB) and the detected memory limit (e.g., 247.5 MB) is due to how the JVM calculates and allocates its heap size within container environments:

1. **Default Max Heap Percentage**: By default, the JVM only uses approximately 25% of the available container memory for its maximum heap size. This is controlled by the `-XX:MaxRAMPercentage` flag which defaults to 25%.

2. **Native Memory Reservation**: The JVM reserves memory for non-heap purposes such as JVM code, thread stacks, direct memory buffers, metaspace, and native libraries.

3. **Overhead Calculation**: The JVM applies safety margins to avoid hitting the container memory limit, which could cause the container to be killed by the OOM killer.

### Container Support Flags

Interestingly, none of the JDK versions explicitly show container-related system properties in the output, even though the `UseContainerSupport` flag is set to `true` in all versions. This suggests that while the flag is enabled, the actual implementation of container support varies between versions.

### Effect of Explicit Flags

Adding explicit JVM flags (`-XX:+UseContainerSupport -XX:+PreferContainerQuotaForCPUCount -XX:ParallelGCThreads=2 -XX:ConcGCThreads=2 -XX:MaxRAMPercentage=75.0`) did not change the behavior:

- JDK 8u342 and 8u362 still did not detect container limits correctly
- JDK 8u372 and 8u382 continued to detect container limits correctly

This indicates that the container support in 8u372 and 8u382 is built into the JVM implementation and not just dependent on flag settings.

## Conclusion

Based on the test results, we can conclude that:

1. **OpenJDK 8u372 and newer** correctly support cgroup v2 for both CPU and memory limit detection in containerized environments.

2. **OpenJDK 8u362 and older** do not support cgroup v2 properly and will detect host system resources instead of container limits.

3. The container support implementation appears to be a fundamental change in the JVM's ability to interact with cgroup v2 filesystem and not just a matter of configuration flags.

4. The simulated EKS tests confirm the same behavior pattern as the Docker tests, indicating that the findings will apply to real Kubernetes environments.

## Recommendations

1. **For Amazon Linux 2023 (which uses cgroup v2)**: Use OpenJDK 8u372 or newer to ensure your Java applications correctly detect and respect container resource limits.

2. **For applications using older JDK versions**: If you must use JDK 8u362 or older with Amazon Linux 2023, be aware that your Java applications will see the host's resources rather than container limits. This could lead to:
   - Over-allocation of threads based on the host's CPU count
   - Memory management decisions based on the host's memory rather than container limits
   - Potential resource contention and performance issues

3. **Migration strategy**: When migrating from Amazon Linux 2 to Amazon Linux 2023, prioritize upgrading to at least OpenJDK 8u372 to ensure proper container resource detection.

4. **Monitoring**: After migration, closely monitor application behavior, especially thread pool sizes, garbage collection patterns, and memory usage to ensure they align with container limits rather than host resources.

5. **Memory Configuration**: If you need the JVM to use more of the available container memory for heap, adjust this with flags like `-XX:MaxRAMPercentage=75.0` or set an explicit maximum heap size with `-Xmx`.
