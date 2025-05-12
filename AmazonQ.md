# OpenJDK 8 cgroup v2 Testing Documentation

This document tracks the execution of tests to verify OpenJDK 8's compatibility with cgroup v2, specifically focusing on resource limit detection in containerized environments.

## Test Plan Overview

1. Create test Java application to detect container resources
2. Create Docker test images with different JDK versions
3. Run local Docker tests with resource constraints
4. Run tests in EKS with Amazon Linux 2023 nodes
5. Analyze results and document findings

## Test Environment

- Local Docker environment for initial testing
- EKS cluster with Amazon Linux 2023 nodes for production-like testing
- Testing JDK versions: 8u342, 8u362, 8u372, 8u382
