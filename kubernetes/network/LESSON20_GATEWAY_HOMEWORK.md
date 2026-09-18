# Lesson 20 — Gateway API и Canary-развёртывание

## Цель работы

Реализовать маршрутизацию HTTP-трафика в Kubernetes через **Gateway API**, без использования Ingress, и направить 80% трафика на стабильную версию приложения и 20% — на canary-версию.

## Подготовка окружения

Использовался профиль Minikube `lesson18` с Docker driver.

```powershell
minikube start -p lesson18
```

Для Gateway API установлен Envoy Gateway:

```powershell
kubectl apply --server-side --force-conflicts -f https://github.com/envoyproxy/gateway/releases/download/v1.9.1/install.yaml
```

Проверка готовности контроллера:

```powershell
kubectl wait --for=condition=Available deployment/envoy-gateway -n envoy-gateway-system --timeout=180s
```

## GatewayClass

В файле [gatewayclass.yaml](gatewayclass.yaml) создан GatewayClass `eg` с контроллером `gateway.envoyproxy.io/gatewayclass-controller`. Статус: `Accepted=True`.

## Приложения

Развёрнуты две версии Go-приложения в namespace `net-demo`:

| Версия | Pod / Service | Ответ |
|---|---|---|
| Stable | `hello-devops` / `hello-devops-svc` | `shalom, DevOps 2079!!!` |
| Canary | `hello-v2` / `hello-v2-svc` | `shalom, version 2!!!` |

Ingress-ресурсы были удалены:

```powershell
kubectl delete ingress hello-devops-ingress hello-v2-ingress -n net-demo
kubectl get ingress -n net-demo
```

Результат: `No resources found in net-demo namespace.`

## Gateway и HTTPRoute

В файле [gateway-canary.yaml](gateway-canary.yaml) созданы:

- Gateway `hello-gateway` с GatewayClass `eg`;
- HTTP listener на порту 80 для `hello.local`;
- HTTPRoute `hello-canary-route`.

Маршрут использует Service backendRefs с весами:

- `hello-devops-svc` — **80**;
- `hello-v2-svc` — **20**.

## Проверка

Для назначения адреса Service типа LoadBalancer был запущен tunnel:

```powershell
minikube -p lesson18 tunnel
```

Gateway получил адрес `127.0.0.1` и статус `PROGRAMMED=True`.

Проверка 100 запросами:

```powershell
1..100 | ForEach-Object {
  (curl.exe -s --resolve "hello.local:80:127.0.0.1" http://hello.local/).Trim()
} | Group-Object | Select-Object Count, Name
```

Результат:

- Stable: **78** запросов;
- Canary: **22** запроса.

Полученное соотношение соответствует настроенным весам 80/20.

## Итог

Задание выполнено: Gateway API заменяет Ingress, оба backend Service доступны, а canary-маршрутизация подтверждена практической проверкой.