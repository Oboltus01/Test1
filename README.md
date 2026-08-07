[![Build hellogo Docker image](https://github.com/Oboltus01/Test1/actions/workflows/docker-build.yml/badge.svg)](https://github.com/Oboltus01/Test1/actions/workflows/docker-build.yml)
[![Terraform](https://github.com/Oboltus01/Test1/actions/workflows/terraform.yml/badge.svg)](https://github.com/Oboltus01/Test1/actions/workflows/terraform.yml)

# Test1

Учебный DevOps-проект для сборки и развёртывания Go-приложения.

## Компоненты

- Go HTTP-сервис `hellogo`, порт `8080`
- Docker multi-stage build
- GitHub Container Registry
- GitHub Actions
- Terraform
- Azure Container Instances
- Azure Storage backend для Terraform state
- Microsoft Entra OIDC-аутентификация без постоянного пароля

## Application URL

http://roman-test1-2079.eastus.azurecontainer.io:8080