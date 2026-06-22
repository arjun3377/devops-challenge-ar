Role: DevOps Engineer
Time: 48 hours from when you start the clock (tell us when you start; we trust you) 
Starting Time: 01:00 PM - 19 June 2026 & Sunday break
Submitting On : 22 June 2026 12:00 PM

**#Security Issues**

**1. Secret exposed via Helm values**

File: templates/deployment.yaml

What's wrong :
          env:
            - name: API_TOKEN
              value: {{ .Values.apiToken | quote }}

Why it matters :
    1) Anyone with access to the values file can read the secret.
    2) Secrets may be committed to Git.

Fix :
    Create a Kubernetes Secret and reference it via secretKeyRef and other possible option - External Secret Operator, Azure Key Vault or Sealed Secrets.


              env:
            - name: API_TOKEN
              valueFrom:
                secretKeyRef:
                  name: api-token
                  key: token


**2. Missing container securityContext**

File: templates/deployment.yaml

What's wrong:
    No container-level security context is defined.

Why it matters:
    The container will likely run as root and retain unnecessary Linux capabilities.

Fix:
        securityContext:
            runAsNonRoot: true
            runAsUser: 10001
            readOnlyRootFilesystem: true
            allowPrivilegeEscalation: false
            seccompProfile:
              type: RuntimeDefault
            capabilities:
              drop:
                - ALL

**3. Image tag is mutable**

File: templates/deployment.yaml

What's wrong:
    image: "skybyte/app:latest"
     No indication that image tags are pinned.

Why it matters:
    If latest or another mutable tag is used then -
        Builds become non-reproducible.
        Rollbacks become difficult.
        Different environments may run different images.

Fix:
    Use immutable image tags.
        options- 
            Tagging with Unique Identifiers (Best Practice) - Used this
            Referencing the Image Digest (Most Secure)

Example:
image: "skybyte/app:v1.1.0-build1" - A Semantic Version coupled with a build number:

**Reliability Issues**

**1) No resource requests or limits**

File: templates/deployment.yaml

What's wrong:  
    No CPU or memory requests/limits. and 
    when you defined ResourceQuota then its mandatory to dedine resource(request & limit).

Why it matters:
    Pod scheduling becomes unpredictable.
    One container can consume excessive node resources.
    Increased risk of OOMKilled containers.

Fix:
         resources:
            requests:
              cpu: 200m
              memory: 200Mi
            limits:
              cpu: 400m
              memory: 400Mi

**2) Liveness and readiness probes are incomplete**

File: templates/deployment.yaml

What's wrong:
livenessProbe:
  httpGet:
    path: /
    port: http

readinessProbe:
  httpGet:
    path: /
    port: http

Probe timing and paths parameters are omitted.

Why it matters:
    Default probe values may cause:
        Premature restarts
        Slow failure detection
        Unnecessary traffic to unhealthy pods

Fix:

livenessProbe:
  httpGet:
    path: /health
    port: http
  initialDelaySeconds: 15
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 3

readinessProbe:
  httpGet:
    path: /ready
    port: http
  initialDelaySeconds: 5
  periodSeconds: 5


**3. Missing startupProbe**

File: templates/deployment.yaml

What's wrong:
    No startup probe exists.

Why it matters:
    Applications with slow startup times may fail liveness checks and restart continuously.

Fix:
    Add a startup probe.

startupProbe:
  httpGet:
    path: /health
    port: http


**4) No graceful shutdown handling**

File: templates/deployment.yaml

What's wrong:
    No lifecycle hook or termination settings.

Why it matters:
    Rolling deployments may terminate active requests.
    Users can receive 5xx errors during deployments.

Fix:
    terminationGracePeriodSeconds: 60
    Application should handle SIGTERM and drain in-flight requests.

lifecycle:
  preStop:
    exec:
      command:
        - sh
        - -c
        - sleep 10


**5) No PodDisruptionBudget**

File: Missing resource

What's wrong:
    No PDB exists.

Why it matters:
    Node upgrades or drains may evict all replicas simultaneously.

Fix:
    Create a PodDisruptionBudget.

apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: skybyte-app-pdb
  namespace: devops-challenge
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: skybyte-app

**10. Single replica risk**

File: deployment.yaml

What's wrong:
    Replica count is configured as 1.

Why it matters:
    Creates a single point of failure.

Fix:
    Production environments should run at least 2 replicas.
    replicaCount: 2 -> Change from 1 to 2 in values.yaml file

**Hygiene Issues**

**1) Namespace hardcoded in manifests**

File: Deployment and Service manifests

What's wrong:
    namespace: {{ .Values.namespace }}

Why it matters:
    Helm already supports namespace management.
    This can create deployment inconsistencies.

Fix:
    namespace: {{ .Release.Namespace }}


**2) No imagePullSecrets support**

File: templates/deployment.yaml

What's wrong:
    No mechanism for private registries.

Why it matters:
    Deployments will fail when using private images.

Fix:
    imagePullSecrets:
      - name: pull-secret


**3) No deployment strategy configuration**

File: templates/deployment.yaml

What's wrong:
    Deployment strategy is not explicitly defined.

Why it matters:
    Production rollouts should clearly define rolling update behavior.

Fix:
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxUnavailable: 0
    maxSurge: 1


**Documentation Issues**

No Changes Yet .