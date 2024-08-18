
Datadog operator deployment using helm: 
https://docs.datadoghq.com/getting_started/containers/datadog_operator/
https://github.com/DataDog/datadog-operator/blob/main/docs/installation.md

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