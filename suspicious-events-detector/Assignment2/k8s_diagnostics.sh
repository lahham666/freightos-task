#!/bin/bash

# Log file for storing diagnostic information
LOG_FILE="/var/log/k8s_diagnostics.log"
echo "Starting diagnostics at $(date)" >> $LOG_FILE

# Function to check pod status and log if issues are found
check_pods() {
  echo "Checking Pods..." >> $LOG_FILE
  kubectl get pods --all-namespaces -o json | jq -r '.items[] | select(.status.phase != "Running" and .status.phase != "Succeeded") | [.metadata.namespace, .metadata.name, .status.phase] | @tsv' | while IFS=$'\t' read -r namespace pod status; do
    echo "Issue: Pod $pod in Namespace $namespace is in $status state." >> $LOG_FILE
    echo "Action: kubectl delete pod $pod -n $namespace" >> $LOG_FILE
  done
}

# Function to check deployment status and log if replicas are not as desired
check_deployments() {
  echo "Checking Deployments..." >> $LOG_FILE
  kubectl get deployments --all-namespaces -o json | jq -r '.items[] | select(.status.readyReplicas != .status.replicas) | [.metadata.namespace, .metadata.name, .status.readyReplicas, .status.replicas] | @tsv' | while IFS=$'\t' read -r namespace deployment ready replicas; do
    echo "Issue: Deployment $deployment in Namespace $namespace has $ready out of $replicas replicas ready." >> $LOG_FILE
    echo "Action: kubectl rollout restart deployment $deployment -n $namespace" >> $LOG_FILE
  done
}

# Function to check service status and log services with no endpoints
check_services() {
  echo "Checking Services..." >> $LOG_FILE
  kubectl get services --all-namespaces -o json | jq -r '.items[] | select(.spec.selector != null and (.status.loadBalancer.ingress | length) == 0) | [.metadata.namespace, .metadata.name] | @tsv' | while IFS=$'\t' read -r namespace service; do
    echo "Issue: Service $service in Namespace $namespace has no external endpoint." >> $LOG_FILE
    echo "Suggestion: Verify pod selectors or consider using a NodePort or ClusterIP service type." >> $LOG_FILE
  done
}

# Run checks for pods, deployments, and services
check_pods
check_deployments
check_services

echo "Diagnostics completed at $(date)" >> $LOG_FILE
echo "----------------------------------------" >> $LOG_FILE
