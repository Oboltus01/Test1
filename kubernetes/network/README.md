Установка ingress addon для minikube:

```bash
minikube addons enable ingress
```

Запуск тоннеля mnikube

```bash
minikube tunnel
```

curl на несуществующий домен

```bash
curl --resolve "hello.local:80:127.0.0.1" http://hello.local/
```