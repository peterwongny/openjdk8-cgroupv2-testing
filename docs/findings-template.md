# OpenJDK 8 cgroup v2 Compatibility Findings

## Summary

This document summarizes the findings from testing OpenJDK 8's compatibility with cgroup v2, specifically focusing on resource limit detection in containerized environments.

## Docker Test Results

| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |
|------------|-----------|-------------|--------------|----------------|-------------------|
| 8u342 | 0.5 | 256m | ? | ? | ? |
| 8u342 | 1 | 512m | ? | ? | ? |
| 8u342 | 2 | 1g | ? | ? | ? |
| 8u362 | 0.5 | 256m | ? | ? | ? |
| 8u362 | 1 | 512m | ? | ? | ? |
| 8u362 | 2 | 1g | ? | ? | ? |
| 8u372 | 0.5 | 256m | ? | ? | ? |
| 8u372 | 1 | 512m | ? | ? | ? |
| 8u372 | 2 | 1g | ? | ? | ? |
| 8u382 | 0.5 | 256m | ? | ? | ? |
| 8u382 | 1 | 512m | ? | ? | ? |
| 8u382 | 2 | 1g | ? | ? | ? |

## Docker Test Results with Explicit Flags

| JDK Version | CPU Limit | Memory Limit | Detected CPUs | Detected Memory | Container Support |
|------------|-----------|-------------|--------------|----------------|-------------------|
| 8u342 | 1 | 512m | ? | ? | ? |
| 8u362 | 1 | 512m | ? | ? | ? |
| 8u372 | 1 | 512m | ? | ? | ? |
| 8u382 | 1 | 512m | ? | ? | ? |

## EKS Test Results

| JDK Version | Detected CPUs | Detected Memory | Container Support |
|------------|--------------|----------------|-------------------|
| 8u362 | ? | ? | ? |
| 8u372 | ? | ? | ? |
| 8u382 | ? | ? | ? |
| 8u362 (explicit flags) | ? | ? | ? |

## Analysis

### CPU Limit Detection

(To be filled after test execution)

### Memory Limit Detection

(To be filled after test execution)

### Container Support Flags

(To be filled after test execution)

## Conclusion

(To be filled after test execution)

## Recommendations

(To be filled after test execution)
