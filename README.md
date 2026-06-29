# Домашнее задание к занятию `«Дипломный практикум в Yandex.Cloud»` - `Демин Герман`

### Цели:

###### Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
###### Запустить и сконфигурировать Kubernetes кластер.
###### Установить и настроить систему мониторинга.
###### Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
###### Настроить CI для автоматической сборки и тестирования.
###### Настроить CD для автоматического развёртывания приложения.

### Этап 1: Создание облачной инфраструктуры

##### Для начала создам через терраформ S3-бакет с versioning для state основной конфигурации. Состояние bootstrap хранится локально — этот шаг выполняется один раз.

```
yc init
yc config list

yc iam create-token

cd terraform-bootstrap

nano terraform.tfvars
```

##### Задаю переменные yandex cloud в terraform.tfvars

`nano outputs.tf`

[/terraform-bootstrap/outputs.tf](/terraform-bootstrap/outputs.tf)

`nano variables.tf`

[/terraform-bootstrap/variables.tf](/terraform-bootstrap/variables.tf)

`nano main.tf`

[/terraform-bootstrap/main.tf](/terraform-bootstrap/main.tf)

```
terraform init

terraform apply

ACCESS_KEY=$(terraform output -raw static_access_key)

SECRET_KEY=$(terraform output -raw static_secret_key)

BUCKET_NAME=$(terraform output -raw bucket_name)
```

##### Копирую данные из Outputs, они пригодятся дальше

![tf-bootstrap](/img/tf-bootstrap.png)

##### Создаётся: service_account, terraform_sa_key, storage_bucket, bucket_static_access_key, bucket_static_secret_key

```
cd ../terraform-infra/

cp ../terraform-bootstrap/terraform.tfvars ./

nano terraform.tfvars
```

##### Убираю значения token и bucket_name

`nano outputs.tf`

[/terraform-infra/outputs.tf](/terraform-infra/outputs.tf)

`nano variables.tf`

[/terraform-infra/variables.tf](/terraform-infra/variables.tf)

`nano main.tf`

[/terraform-infra/main.tf](/terraform-infra/main.tf)

```
terraform init \
  -backend-config="bucket=$BUCKET_NAME" \
  -backend-config="access_key=$ACCESS_KEY" \
  -backend-config="secret_key=$SECRET_KEY" \
  -backend-config="endpoint=https://storage.yandexcloud.net" \
  -backend-config="region=ru-central1-a"
```

`terraform apply`

![tf-infra](/img/tf-infra.png)

##### Создаётся: VPC + 3 подсети (a/b/d), Managed K8s кластер (зональный), node group (прерываемые ВМ), Container Registry, CI/CD SA.



### Этап 2: Создание Kubernetes кластера

`cd ../k8s/`

[/k8s/app/deployment.yaml](/k8s/app/deployment.yaml)

[/k8s/monitoring/values.yaml](/k8s/monitoring/values.yaml)

```
yc managed-kubernetes cluster get-credentials k8s-cluster --external --force

kubectl get pods --all-namespaces
```

![k8s](/img/k8s.png)



### Этап 3: Создание тестового приложения

`cd ../app`

[/app/index.html](app/index.html)

[/app/nginx.conf](/app/nginx.conf)

[/app/Dockerfile](/app/Dockerfile)

```

docker build --build-arg VERSION=dev -t diploma-app:dev .

docker push cr.yandex/crpdvmq6cdd1gcj82j4g/diploma-app:v1
```

![app-1](/img/app-1.png)

`docker run -p 8080:80 diploma-app:dev  `

![app-2](/img/app-2.png)

![app-3](/img/app-3.png)

```
git init

git remote add origin git@github.com:awakehns/deploy-app.git

git add .

git commit -m "."

git branch -m main

git push origin main
```

#### Репозиторий тестового приложения

##### https://github.com/awakehns/deploy-app



### Этап 4: Подготовка cистемы мониторинга и деплой приложения

#### Мониторинг

```
cd ..

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

helm repo update

export GODEBUG=http2client=0 # Без этого не идёт скачивание с helm

helm upgrade --install monitoring prometheus-community/kube-prometheus-stack \
  --namespace monitoring \
  --create-namespace \
  --values k8s/monitoring/values.yaml
  
kubectl get pods -n monitoring -w
```

##### Проверяем prometheus

`kubectl port-forward -n monitoring svc/monitoring-kube-prometheus-prometheus 9090:9090`

![prometheus](/img/prometheus.png)

##### Проверяем grafana

`kubectl get svc -n monitoring monitoring-grafana`

![grafana](/img/grafana.png)

#### Деплой инфраструктуры в terraform pipeline

Изменения в `terraform-infra/` автоматически запускают GitHub Actions workflow [`.github/workflows/terraform.yaml`](.github/workflows/terraform.yaml):

- **Pull Request** → выполняется `terraform plan`, результат виден в PR-проверках.
- **Push в `main`** → выполняется `terraform apply` автоматически.

Необходимые секреты в репозитории:

После применения — деплой приложения:

```
kubectl apply -f k8s/app/deployment.yaml

kubectl get ingress diploma-app
```

Так же старый ключ был отозван сразу после завершения задания. Теперь новый ключ добавлен в .gitignore

![app-4](/img/app-4.png)



### Этап 5: Установка и настройка CI/CD

##### Добавляю ключи в репозиторий git

###### YC_SA_JSON_KEY      # содержимое cicd-sa-key.json
###### YC_REGISTRY_ID       # terraform output registry_id
###### YC_CLOUD_ID           # terraform output cloud_id
###### YC_FOLDER_ID          # terraform output folder_id
###### YC_K8S_CLUSTER_ID # terraform output cluster_id

```
git init

git remote add origin git@github.com:awakehns/yc-diplom.git

git branch -m main

git add .

git commit --allow-empty -m "test ci"

git push --set-upstream origin main
```

##### Чищу yandex cloud

```
cd ../terraform-infra

terraform destroy

cd ../terraform-bootstrap

terraform destroy
```
