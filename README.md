
# Диплом в Cloud: Amazon Web Services"

## Цели:
1. Подготовить облачную инфраструктуру на базе облачного провайдера AWS.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

## Этапы выполнения:  

## Создание облачной инфраструктуры
Подготовлена конфигурация Terraform для развёртывания ресурсов в AWS. Все предварительные тесты проводились на собственном тестовом аккаунте AWS. Для работы используется такая версия Terraform:
```
$ (master)terraform --version
Terraform v1.1.6
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v3.74.3
```
  В ходе работы Terraform, система разворачивает 3 шт ВМ с операционной системой Ubuntu 20.04. Созданы 2 workspace с названиями prod и stage.  
```
$ terraform workspace list
* prod
  stage
  ```
  В пространстве stage формируются 3 ВМ типа "t2.micro", для prod - 3 ВМ типа "t3.small". 
См. каталог devops-diplom-terraform-master
```
$ (master)terraform apply "myplan"
aws_dynamodb_table.dynamodb-terraform-lock: Creating...
aws_s3_bucket.netology-diplom-bucket: Creating...
aws_dynamodb_table.dynamodb-terraform-lock: Still creating... [10s elapsed]
aws_s3_bucket.netology-diplom-bucket: Still creating... [10s elapsed]
aws_dynamodb_table.dynamodb-terraform-lock: Creation complete after 10s [id=terraform-lock]
aws_s3_bucket.netology-diplom-bucket: Creation complete after 13s [id=netology-diplom-bucket]

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:

region = "us-east-1"
```
* В основной папке проекта проводим инициализацию бекенда, делаем планирование и убеждаемся, что всё срабатывает.
```
$ (master)terraform apply "myplan"
Acquiring state lock. This may take a few moments...
module.vpc.aws_subnet.public[0]: Creating...
aws_instance.diplom_instance[2]: Creating...
aws_instance.diplom_instance[1]: Creating...
aws_instance.diplom_instance[0]: Creating...
.....
Releasing state lock. This may take a few moments...
Apply complete! Resources: 5 added, 0 changed, 0 destroyed.
```
Тестовые подключения к ВМ выполнились успешно. В качестве примера, такая конфигурация у одной из ВМ:
```
Welcome to Ubuntu 20.04.4 LTS (GNU/Linux 5.13.0-1017-aws x86_64)
$ free -m
              total        used        free      shared  buff/cache   available
Mem:           1939         144        1430           0         364        1643
Swap:             0           0           0
$ cat /proc/cpuinfo
processor	: 0
vendor_id	: GenuineIntel
model name	: Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz
processor	: 1
vendor_id	: GenuineIntel
model name	: Intel(R) Xeon(R) Platinum 8259CL CPU @ 2.50GHz
```
Такой конфигурации хватит для запуска control plane и для работы с подами с приложением.
 
##  Создание Kubernetes кластера
```
PLAY RECAP **************************************************************************************************************************************************************
localhost                  : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
node1                      : ok=565  changed=124  unreachable=0    failed=0    skipped=1141 rescued=0    ignored=2   
node2                      : ok=369  changed=76   unreachable=0    failed=0    skipped=644  rescued=0    ignored=1   
node3                      : ok=369  changed=76   unreachable=0    failed=0    skipped=643  rescued=0    ignored=1
```
Для просмотра состояния кластера, выполнен вход на первую ноду (на ней находится control plane):

```
~# kubectl get nodes
NAME    STATUS   ROLES                  AGE   VERSION
node1   Ready    control-plane,master   25m   v1.21.3
node2   Ready    <none>                 24m   v1.21.3
node3   Ready    <none>                 24m   v1.21.3
```
Просматриваем состояние активных после инсталляции подов во всех неймспейсах:
```
root@node1:~# kubectl get pods --all-namespaces
NAMESPACE     NAME                                       READY   STATUS    RESTARTS   AGE
kube-system   calico-kube-controllers-5b4d7b4594-gkpjs   1/1     Running   1          24m
kube-system   calico-node-5fd9x                          1/1     Running   0          25m
kube-system   calico-node-9ts7d                          1/1     Running   0          25m
kube-system   calico-node-g88fs                          1/1     Running   0          25m
kube-system   coredns-8474476ff8-7wrjd                   1/1     Running   0          22m
kube-system   coredns-8474476ff8-g722v                   1/1     Running   0          22m
kube-system   dns-autoscaler-7df78bfcfb-dwgl7            1/1     Running   0          22m
kube-system   kube-apiserver-node1                       1/1     Running   0          27m
kube-system   kube-controller-manager-node1              1/1     Running   0          27m
kube-system   kube-proxy-5zd7h                           1/1     Running   0          26m
kube-system   kube-proxy-j2mt8                           1/1     Running   0          26m
kube-system   kube-proxy-lph28                           1/1     Running   0          26m
kube-system   kube-scheduler-node1                       1/1     Running   0          27m
kube-system   nginx-proxy-node2                          1/1     Running   0          26m
kube-system   nginx-proxy-node3                          1/1     Running   0          26m
kube-system   nodelocaldns-8t8zj                         1/1     Running   0          22m
kube-system   nodelocaldns-lql2n                         1/1     Running   0          22m
kube-system   nodelocaldns-zwb6m                         1/1     Running   0          22m
```
## Создание тестового приложения

В качестве тестового приложения используется статическая страница, которая обрабатывается сервером Nginx. Для работы с контейнеризованным приложением был выбран [официальный образ](https://hub.docker.com/_/nginx "официальный образ") приложения, причём версия на базе наименьшего по объёму Alpine.  
См. каталог devops-diplom-terraform-master
## Подготовка Kubernetes конфигурации

* Для развёртывания системы мониторинга был пакет [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus.git). Для возможности обращаться к веб интерфейсу Grafana, в манифест сервиса был добавлен NodePort на порт 30000. Этот порт был раннее devops-diplom-terraform-master\security.tfsecurity.tf в конфигурации VPC в Terraform. Выполняем последовательно команды для создания всех необходимых ресурсов:
```
# kubectl create -f manifests/setup/
customresourcedefinition.apiextensions.k8s.io/alertmanagerconfigs.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/alertmanagers.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/podmonitors.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/probes.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/prometheuses.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/prometheusrules.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/servicemonitors.monitoring.coreos.com created
customresourcedefinition.apiextensions.k8s.io/thanosrulers.monitoring.coreos.com created
*namespace/monitoring created

# kubectl create -f manifests/
```
Можно посмотреть, что создалось в системе:

```
# kubectl get pods -n monitoring
NAME                                   READY   STATUS    RESTARTS   AGE
alertmanager-main-0                    2/2     Running   0          57s
alertmanager-main-1                    2/2     Running   0          57s
alertmanager-main-2                    2/2     Running   0          57s
blackbox-exporter-676d976865-7ccf4     3/3     Running   0          73s
grafana-6c4c6b8fb7-k6ggk               1/1     Running   0          73s
kube-state-metrics-5d6885d89-46hbt     3/3     Running   0          72s
node-exporter-25l26                    2/2     Running   0          72s
node-exporter-62cm5                    2/2     Running   0          72s
node-exporter-fr9hx                    2/2     Running   0          72s
prometheus-adapter-6cf5d8bfcf-4hrl8    1/1     Running   0          72s
prometheus-adapter-6cf5d8bfcf-jgwk8    1/1     Running   0          72s
prometheus-k8s-0                       2/2     Running   0          56s
prometheus-k8s-1                       2/2     Running   0          56s
prometheus-operator-7f58778b57-c8wk7   2/2     Running   0          71s

# kubectl get svc -n monitoring
NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                      AGE
alertmanager-main       ClusterIP   10.233.41.206   <none>        9093/TCP,8080/TCP            100s
alertmanager-operated   ClusterIP   None            <none>        9093/TCP,9094/TCP,9094/UDP   84s
blackbox-exporter       ClusterIP   10.233.62.171   <none>        9115/TCP,19115/TCP           100s
grafana                 NodePort    10.233.19.163   <none>        3000:30000/TCP               100s
kube-state-metrics      ClusterIP   None            <none>        8443/TCP,9443/TCP            99s
node-exporter           ClusterIP   None            <none>        9100/TCP                     99s
prometheus-adapter      ClusterIP   10.233.32.41    <none>        443/TCP                      99s
prometheus-k8s          ClusterIP   10.233.55.195   <none>        9090/TCP,8080/TCP            99s
prometheus-operated     ClusterIP   None            <none>        9090/TCP                     83s
prometheus-operator     ClusterIP   None            <none>        8443/TCP                     99s
```
Видно, что существует сервис Grafana на нужном порту, который будет доступен на внешнем IP адресе. 

* devops-diplom-ansible-master с конфигурационными файлами для настройки Kubernetes.
* [Http доступ](http://3.94.159.165:30000/login "Http доступ") к web интерфейсу grafana. (вход осуществляется под учётными данными **admin:admin**)
* Дашборды в grafana отображающие состояние Kubernetes кластера.
* [Http доступ](http://3.94.159.165:30001 "Http доступ") к тестовому приложению.

