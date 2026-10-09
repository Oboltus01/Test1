# Lesson 21 — Kubernetes Storage (18.09.2026)

DevOps 2079 laboratory. Based on [the teacher's lesson commit](https://github.com/BorisovCloud/devops2079/commit/a107f511fd95a2142bd3dc40cb9f8c1070fe38a0).

## Goals

Practice ConfigMap mounts, `emptyDir`, static PersistentVolume (PV) and PersistentVolumeClaim (PVC), and CSI dynamic provisioning. Verify data survives Pod recreation.

## Environment

- Windows 11 / PowerShell / VS Code
- Minikube profile: `lesson18`; namespace: `storage-demo`
- Nginx 1.24 and BusyBox containers

Commands below assume your terminal is in `kubernetes/storage`. When creating resources for the first time, use `kubectl create namespace storage-demo`; if it already exists, skip that command. Select the correct context with `kubectl config use-context lesson18`.

## 1. ConfigMap, folder mount and file mount

```powershell
kubectl create configmap index-config -n storage-demo --from-file=nginx_index.html
kubectl apply -f .\nginx-mount-folder.yaml
kubectl get deployments,pods,configmaps -n storage-demo
kubectl exec -n storage-demo deployment/nginx-mount-folder -- cat /usr/share/nginx/html/index.html
kubectl port-forward -n storage-demo deployment/nginx-mount-folder 8080:80
```

Open http://localhost:8080. Stop port forwarding with Ctrl+C. The folder-mount Deployment uses three replicas.

```powershell
kubectl apply -f .\nginx-mount-file.yaml
kubectl exec -n storage-demo deployment/nginx-mount-file -- cat /usr/share/nginx/html/index.html
```

The second Deployment mounts only `index.html` via `subPath`. Changes to a ConfigMap-mounted file through `subPath` do not automatically propagate to a running container. The manifests also demonstrate `emptyDir`, which is temporary storage tied to a Pod.

Optionally remove the Nginx Deployments before the next exercise:

```powershell
kubectl delete deployment nginx-mount-folder nginx-mount-file -n storage-demo
```

## 2. Static PV and PVC

```powershell
kubectl apply -f .\pv.yaml
kubectl apply -f .\pvc.yaml
kubectl get pv
kubectl get pvc -n storage-demo
```

- `pv-hostpath`: 1Gi, `ReadWriteOnce`, `manual` StorageClass, `Retain` reclaim policy, node path `/mnt_data`.
- `pvc-hostpath`: requests 500Mi and binds to the 1Gi PV.

```powershell
kubectl apply -f .\pod.yaml
kubectl wait --for=condition=Ready pod/pv-demo -n storage-demo --timeout=120s
kubectl exec -n storage-demo pv-demo -- cat /mnt/storage/date.txt
kubectl delete pod pv-demo -n storage-demo
kubectl apply -f .\pod.yaml
kubectl wait --for=condition=Ready pod/pv-demo -n storage-demo --timeout=120s
kubectl exec -n storage-demo pv-demo -- cat /mnt/storage/date.txt
```

Observed result: both the old timestamp and a new timestamp remained in `date.txt` after recreating the Pod. Note: `hostPath` is appropriate for this single-node training lab, not general production storage.

## 3. CSI dynamic provisioning

```powershell
minikube -p lesson18 addons enable csi-hostpath-driver
minikube -p lesson18 addons enable volumesnapshots
kubectl get csidrivers
kubectl get storageclass
kubectl get pods -n kube-system
```

The CSI driver `hostpath.csi.k8s.io` provides StorageClass `csi-hostpath-sc`. Create only the claim; the PV is dynamically provisioned.

```powershell
kubectl apply -f .\csi-pvc.yaml
kubectl get pvc -n storage-demo
kubectl get pv
kubectl apply -f .\csi-pod.yaml
kubectl wait --for=condition=Ready pod/csi-pod -n storage-demo --timeout=120s
kubectl exec -n storage-demo csi-pod -- cat /data/test.txt
```

BusyBox appends a timestamp to `/data/test.txt` every 10 seconds. Check persistence across recreation:

```powershell
kubectl delete pod csi-pod -n storage-demo
kubectl apply -f .\csi-pod.yaml
kubectl wait --for=condition=Ready pod/csi-pod -n storage-demo --timeout=120s
kubectl exec -n storage-demo csi-pod -- cat /data/test.txt
kubectl get pods,pvc -n storage-demo
kubectl get pv
```

**Observed result:** earlier timestamps remained after Pod recreation, and new timestamps continued appearing. The PVC remained bound to the same dynamically provisioned PV.

## Storage concepts

| Mechanism | Role | Lifetime |
|---|---|---|
| ConfigMap volume | Supply configuration files to containers | ConfigMap exists independently of the Pod |
| `emptyDir` | Scratch space shared by containers in one Pod | Removed with the Pod |
| PV | Represents a Kubernetes storage volume | Governed by volume/reclaim policy |
| PVC | Requests storage for a Pod | Separate from Pod lifecycle |
| CSI driver | Integrates Kubernetes with storage provisioners | Depends on backend and reclaim policy |

## Cleanup (optional; destructive)

Do **not** run this section if you want to preserve lab data. In particular, the CSI PV uses reclaim policy `Delete`, so removing its PVC can delete its backing data. The static PV uses `Retain`; deleting the PV object may still leave files on the Minikube node.

```powershell
kubectl delete namespace storage-demo
kubectl delete pv pv-hostpath
```

## Outcome

Successfully demonstrated ConfigMap-backed Nginx content, folder versus file mounts, static PV/PVC binding, CSI dynamic provisioning, and retention of stored timestamps when Pods are recreated.
