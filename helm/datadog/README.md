
Datadog operator deployment using helm: 
https://docs.datadoghq.com/getting_started/containers/datadog_operator/
https://github.com/DataDog/datadog-operator/blob/main/docs/installation.md
https://github.com/DataDog/helm-charts/blob/main/charts/datadog/README.md

Step 1: Encode the Secret Data with Base64

    First, you need to encode the sensitive data (e.g., an API key) using base64.
        1. Encode the API key using base64:
            echo -n "2b1e77d9e7448c6afbf9e774e6d9bfd8" | base64
            echo -n "96008afa99d2f292bb0f3fbcbdcd08d27942ad71" | base64

            The -n option in echo prevents adding a newline character to the string, which would alter the base64 output.

            The output will be something like:
            MmIxZTc3ZDllNzQ0OGM2YWZiZjllNzc0ZTZkOWJmZDg=
            OTYwMDhhZmE5OWQyZjI5MmJiMGYzZmJjYmRjZDA4ZDI3OTQyYWQ3MQ==

            This is your base64-encoded API key.

Step 2: Create the Secret Manifest

    Next, create a YAML file for the Kubernetes secret. Let's name it datadog-secret.yml.

apiVersion: v1
kind: Secret
metadata:
  name: datadog-secret
  namespace: <your-namespace>  # Replace with your namespace
type: Opaque
data:
  api-key: MmIxZTc3ZDllNzQ0OGM2YWZiZjllNzc0ZTZkOWJmZDg=  # Replace with your base64 encoded key

    2.1. Replace <your-namespace> with the name of your namespace. If you’re using the default namespace, you can omit the namespace line.

    2.2. The api-key value is the base64 encoded string from the previous step.

Step 3: Apply the Secret to the Kubernetes Cluster

    3.1. kubectl apply -f datadog-secret.yml

apiVersion: datadoghq.com/v2alpha1
kind: DatadogAgent
metadata:
  name: datadog
  namespace: demo
spec:
  global:
    containerStrategy: single
    credentials:
      apiSecret:
        secretName: datadog-secret
        keyName: api-key
  features:
    apm:
      enabled: true
    logCollection:
      enabled: true

OR

apiVersion: datadoghq.com/v2alpha1
kind: DatadogAgent
metadata:
  name: datadog
spec:
  global:
    clusterName: my-example-cluster
    containerStrategy: single
    credentials:
      apiSecret:
        secretName: datadog-secret
        keyName: api-key
      appSecret:
        secretName: datadog-secret
        keyName: app-key
  features:
    logCollection:
      enabled: true
    liveProcessCollection:
      enabled: true
    liveContainerCollection:
      enabled: true
    processDiscovery:
      enabled: true
    oomKill:
      enabled: true
    tcpQueueLength:
      enabled: true
    ebpfCheck:
      enabled: true
    apm:
      enabled: true
    cspm:
      enabled: true
    cws:
      enabled: true
    npm:
      enabled: true
    usm:
      enabled: true
    dogstatsd:
      unixDomainSocketConfig:
        enabled: true
    otlp:
      receiver:
        protocols:
          grpc:
            enabled: true
    remoteConfiguration:
      enabled: true
    sbom:
      enabled: true
    eventCollection:
      collectKubernetesEvents: true
    orchestratorExplorer:
      enabled: true
    kubeStateMetricsCore:
      enabled: true
    admissionController:
      enabled: true
    externalMetricsServer:
      enabled: true
    clusterChecks:
      enabled: true
    prometheusScrape:
      enabled: true
###################################   OR    ############################################

Process to setup DD agent in EKS:

Step01. Add helm repo for DD Agent
		helm repo add datadog https://helm.datadoghq.com
		helm repo update
		
Step02. Download DD Agent helm chart in loacal
		helm pull datadog/datadog --untar

Step03. Customize values.yml file as per your requirement

datadog:
  apiKey: "<YOUR_DATADOG_API_KEY>"
  appKey: "<YOUR_DATADOG_APP_KEY>"
  
  # Enable APM
  apm:
    enabled: true
    
  # Enable Kubernetes monitoring
  kubeStateMetricsEnabled: true
  clusterChecksEnabled: true
  
  # Enable logs
  logs:
    enabled: true
    
  # Enable process monitoring
  processAgent:
    enabled: true

  # Enable NGINX monitoring
  confd:
    nginx.yaml: |
      ad_identifiers:
        - nginx
      logs:
        - type: file
          path: /var/log/nginx/access.log
          service: nginx
          source: nginx

  # Monitor the curl container
  confd:
    curl.yaml: |
      ad_identifiers:
        - curl
      logs:
        - type: file
          path: /var/log/curl.log
          service: curl
          source: curl

  # Set cluster name for easier identification in Datadog
  clusterName: "my-eks-cluster"

OR

datadog:
  apiKey: "<YOUR_DATADOG_API_KEY>"
  appKey: "<YOUR_DATADOG_APP_KEY>"

  # General configurations
  clusterName: "my-eks-cluster"  # Replace with your actual cluster name
  
  # Kubernetes monitoring
  kubeStateMetricsEnabled: true
  clusterChecksEnabled: true
  
  # Enable APM (Application Performance Monitoring)
  apm:
    enabled: true

  # Enable logs
  logs:
    enabled: true
    containerCollectAll: true   # Collect logs from all containers
    logsConfigContainerCollectUsingFiles: true  # Use file-based collection

  # Enable process monitoring
  processAgent:
    enabled: true
  
  # Enable network performance monitoring
  networkMonitoring:
    enabled: true

  # Enable security monitoring
  securityAgent:
    compliance:
      enabled: true
    runtime:
      enabled: true

  # NGINX-specific monitoring
  confd:
    nginx.yaml: |
      ad_identifiers:
        - nginx
      init_config:
      instances:
        - nginx_status_url: http://localhost/nginx_status
          tags:
            - "app:nginx"
      logs:
        - type: file
          path: /var/log/nginx/access.log
          service: nginx
          source: nginx
        - type: file
          path: /var/log/nginx/error.log
          service: nginx
          source: nginx
      logsConfig:
        containerCollectAll: true
        containerCollectUsingFiles: true

  # Synthetic monitoring setup (if required)
  synthetics:
    enabled: true

  # Real User Monitoring (RUM) - if applicable
  rum:
    enabled: true
    applicationID: "<YOUR_RUM_APPLICATION_ID>"
    clientToken: "<YOUR_RUM_CLIENT_TOKEN>"

  # Service monitoring - if NGINX is part of a larger service
  service:
    name: nginx-service
    type: web

  # Integrations - add more if required
  # For example, monitoring databases or caches used by NGINX
  redisdb:
    enabled: true
    instances:
      - host: "localhost"
        port: 6379
        tags:
          - "service:redis"
          
  mysql:
    enabled: true
    instances:
      - host: "localhost"
        port: 3306
        username: "root"
        password: "<YOUR_MYSQL_PASSWORD>"
        tags:
          - "service:mysql"
  
  # Custom metrics (if any)
  customMetrics:
    enabled: true
    instances:
      - custom_metric_name: nginx.custom_metric
        query: "sum:nginx.requests.count{*} by {host}"

  # Synthetic tests (if you want to set up uptime checks or API monitoring)
  synthetics:
    enabled: true
    tests:
      - name: "Homepage Check"
        type: "api"
        request:
          method: "GET"
          url: "http://your-nginx-service/homepage"
        assertions:
          - type: "statusCode"
            operator: "is"
            target: 200
          - type: "responseTime"
            operator: "lessThan"
            target: 2000

# Configurations for other aspects of the EKS cluster monitoring can be added here as needed.

Key Sections Explained
1. Kubernetes Monitoring: Enables monitoring of Kubernetes cluster metrics.
2. APM: Enables Application Performance Monitoring, which tracks traces, latency, and errors.
3. Logs: Configured to collect logs from NGINX containers, including access and error logs.
4. Process Monitoring: Tracks the processes running in the container.
5. Network Performance Monitoring: Monitors the network I/O and performance.
6. Security Monitoring: Includes compliance and runtime security checks.
7. NGINX-Specific Monitoring: Configures Datadog to collect metrics and logs from the NGINX server.
8. Synthetic Monitoring: Sets up synthetic tests for uptime and API checks.
9. RUM (Real User Monitoring): If applicable, tracks real user interactions with the NGINX server.
10. Custom Metrics: Allows you to define custom metrics specific to your NGINX deployment.
11. Service Monitoring: Monitors the NGINX service as part of a larger service infrastructure.

Step04. Pre-requisites for EKS/k8s monitoring.
		1. Metrics Server Installed: Ensure the Kubernetes Metrics Server is installed and running in your cluster. The Metrics Server provides resource usage metrics, such as CPU and memory usage, that Datadog uses for monitoring.
		kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
		
		helm repo add bitnami https://charts.bitnami.com/bitnami
		helm repo update
		helm install metrics-server bitnami/metrics-server
		kubectl get deployment metrics-server -n kube-system


		2. Kube-State-Metrics Deployment: The Datadog Agent relies on kube-state-metrics to collect detailed information about the state of the Kubernetes objects, such as deployments, nodes, and pods.
		kubectl apply -f https://github.com/kubernetes/kube-state-metrics/releases/latest/download/kube-state-metrics.yaml
		
		helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
		helm repo update
		helm install kube-state-metrics prometheus-community/kube-state-metrics
		kubectl get deployment kube-state-metrics -n default

    