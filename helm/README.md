# Lesson 25 — Helm

## Environment
- Helm v4.3.1
- Kubernetes v1.35.1
- Minikube profile: lesson18
- Chart: podinfo 6.15.0

## Install
helm repo add stefanprodan https://stefanprodan.github.io/podinfo
helm repo update
helm upgrade -i podinfo stefanprodan/podinfo --version 6.15.0

## Download chart
helm pull stefanprodan/podinfo --version 6.15.0 --untar

## Upgrade to 3 replicas
helm upgrade podinfo .\helm\podinfo -f .\helm\myvalues.yaml
kubectl rollout status deployment/podinfo
kubectl get deployment podinfo

Result: 3/3 replicas, revision 3.

## Rollback
helm rollback podinfo 2

Result: 1/1 replica, revision 4.

## Final upgrade
helm upgrade podinfo .\helm\podinfo -f .\helm\myvalues.yaml

Result: 3/3 replicas, revision 5, deployed.

## Verification
helm history podinfo
helm status podinfo
kubectl get deployment podinfo

## Conclusion
Helm install, upgrade and rollback completed successfully.

## Additional Helm files

- `myvalues.yaml` - custom configuration with 3 replicas.
- `podinfovalues.yaml` - default Podinfo chart values.
- `argovalues.yaml` - default Argo CD chart values.
- `release.json` - metadata of the installed Podinfo release.

## Export commands

```powershell
helm show values stefanprodan/podinfo --version 6.15.0 > podinfovalues.yaml
helm show values argo/argo-cd > argovalues.yaml
helm get metadata podinfo -o json > release.json
```

Note: release.json contains release metadata, not the complete Helm release object.
