#!/bin/bash

# set -x 
echo -e "\nPrints the in-container UID (proving non-root)\n"
kubectl exec -it `kubectl get pod -A | grep skybytech | awk '{print $2}'` -n devops-challenge -- id

echo -e " \nPrints the bound port and capabilities.\n"
helm get all skybytech | grep -A 2 capabilities
helm get all skybytech | grep -C 2 containerPort

echo -e "\nCurls / and validates the response body\n"
kubectl port-forward service/`kubectl get service -A | grep skybytech | awk '{print $2}'` -n devops-challenge 8080:80 >/tmp/pf.log 2>&1 &
PID=$!
sleep 5
curl http://localhost:8080
echo -e " \nCurls //metrics and greps for http_requests_total\n"
curl http://localhost:8080/metrics | grep http_requests_total.
kill $PID

sleep 5

echo -e "\nDeleting pod\n"
START=$(date +%s)
kubectl delete pod `kubectl get pod -A | grep skybytech | awk '{print $2}'` -n devops-challenge

kubectl rollout status deployment/`kubectl get deployment -A | grep skybytech | awk '{print $2}'` -n devops-challenge --timeout=30s

END=$(date +%s)

DURATION=$((END-START))

echo -e "\nTotal Second taken for rollout $DURATION \n"

if [ "$DURATION" -gt 30 ]; then
  echo -e "\nFAIL: Recovery exceeded 30 seconds\n"
  exit 1
fi

echo -e "\nPASS: Deployment recovered successfully\n"