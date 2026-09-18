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

## Контекст: урок 18 — сеть и базовые ресурсы

Перед уроком 20 был подготовлен кластерный профиль `lesson18` на базе Minikube и Docker driver с Calico CNI:

```powershell
minikube start -p lesson18 --driver=docker --cni=calico
```

### Namespaces и изоляция

Использовались три namespace:

| Namespace | Назначение |
|---|---|
| `net-demo` | Демонстрационные приложения и Service |
| `net-clients` | Разрешённые клиенты |
| `net-untrusted` | Неразрешённые клиенты |

### NetworkPolicy

В `net-demo` была создана NetworkPolicy для Pod с меткой `app: nginx`. Она:

- разрешала входящий TCP-трафик на порт 80 только от Pod с меткой `access: allowed` из namespace `net-clients`;
- запрещала доступ из `net-untrusted`;
- разрешала исходящий DNS-трафик к CoreDNS в `kube-system` по UDP/TCP 53.

Проверка показала, что запрос из `net-untrusted` к `nginx-service` не проходит, а разрешённый клиент из `net-clients` может обращаться к Service.

### ConfigMap и Secret

Также были проверены:

- ConfigMap с приветствием для приложения;
- Secret с именем пользователя, переданным в Pod через переменную окружения.

### Связь с уроком 20

Урок 18 настроил сетевую основу кластера: namespace, Service, DNS и NetworkPolicy. В уроке 20 поверх этой основы внешний HTTP-маршрут реализован через Gateway API вместо Ingress.


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