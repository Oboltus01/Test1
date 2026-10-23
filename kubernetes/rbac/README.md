# Lesson 24 - Kubernetes RBAC

Date: 23.10.2026
Based on Anton's Kubernetes RBAC lesson.

## Environment

- Minikube profile: lesson18
- Kubernetes: v1.35.1
- Namespace: team-a

## Resources

- sa.yaml: ServiceAccount ci-deployer
- role.yaml: Role pod-reader
- rolebinding.yaml: RoleBinding pod-reader-binding

## Permissions

The pod-reader Role permits:
- get pods
- list pods
- watch pods

The Role does not permit:
- create pods
- delete pods

Permissions are limited to namespace team-a.

## Verification

| Operation | Result |
|---|---|
| get pods in team-a | yes |
| list pods in team-a | yes |
| create pods in team-a | no |
| delete pods in team-a | no |
| get pods in default | no |

## Conclusion

RBAC successfully restricts ServiceAccount
ci-deployer to read-only access to Pods
within namespace team-a.

This demonstrates the Principle of Least Privilege.
