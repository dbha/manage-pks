##### mariadb-galera 배포후 ClusterMetricSink 생성   

##### 01. mariadb-galera 배포를 위한 repo add   
    ubuntu@opsmgr-02:~/yaml/nginx$ helm repo add bitnami-ibm https://charts.bitnami.com/ibm
    "bitnami-ibm" has been added to your repositories
    
    ubuntu@opsmgr-02:~/yaml/nginx$ helm repo list
    NAME       	URL
    elastic    	https://Helm.elastic.co
    jupyterhub 	https://jupyterhub.github.io/helm-chart/
    bitnami    	https://charts.bitnami.com/bitnami
    bitnami-ibm	https://charts.bitnami.com/ibm
    
##### 02. Fetch Chart
    ubuntu@opsmgr-02:~/yaml/mariadb-galera$ helm fetch bitnami-ibm/mariadb-galera
    
    ubuntu@opsmgr-02:~/yaml/mariadb-galera$ ls
    mariadb-galera-4.3.2.tgz
    
    ubuntu@opsmgr-02:~/yaml/mariadb-galera$ ls -lrt
    total 32
    -rw-r--r-- 1 ubuntu ubuntu 29661 Aug 10 00:55 mariadb-galera-4.3.2.tgz    
    
    ubuntu@opsmgr-02:~/yaml/mariadb-galera$ tar xvf mariadb-galera-4.3.2.tgz
    mariadb-galera/Chart.yaml
    mariadb-galera/values.yaml
    mariadb-galera/values.schema.json
    mariadb-galera/templates/NOTES.txt
    mariadb-galera/templates/_helpers.tpl
    mariadb-galera/templates/configmap.yaml
    mariadb-galera/templates/headless-svc.yaml

##### 04. custom-values.yaml 생성  
    ubuntu@opsmgr-02:~/yaml/mariadb-galera/mariadb-galera$ cp values.yaml customer-values.yaml
    
    -> customer-values.yaml 내 Persistent 를 false, metrics 을 true로 수정
    ubuntu@opsmgr-02:~/yaml/mariadb-galera/mariadb-galera$ vi customer-values.yaml
    
##### 05. mariadb-galera 생성   

    ubuntu@opsmgr-02:~/yaml/mariadb-galera/mariadb-galera$ helm install mariadb-galera -f customer-values.yaml ./
    NAME: mariadb-galera
    LAST DEPLOYED: Mon Aug 10 00:58:03 2020
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    TEST SUITE: None
    NOTES:
    ** Please be patient while the chart is being deployed **
    
##### 06. 확인
    -> 하나의 Pod에 두개의 Container 가(mariadb-galera, metrics) 배포된 구조
    ubuntu@opsmgr-02:~/yaml/mariadb-galera/mariadb-galera$ kubectl get po
    NAME               READY   STATUS    RESTARTS   AGE
    mariadb-galera-0   2/2     Running   0          2m14s
    mariadb-galera-1   2/2     Running   0          89s
    mariadb-galera-2   2/2     Running   0          37s
    
##### 07. mariadb-galera를 위한 sink resource 생성   

    ubuntu@opsmgr-02:~/sink$ kubectl apply -f mariadb-cluster-metric-sink.yaml
    clustermetricsink.pksapi.io/mariadb-cluster-metric-sink created
    
    ubuntu@opsmgr-02:~/sink$ kubectl get clustermetricsink
    NAME                          AGE
    mariadb-cluster-metric-sink   10s        
    
##### 08. telegraf 로그 확인

    -> 9104 port로 mariadb metric Expose
    ubuntu@opsmgr-02:~/sink$ kubectl logs -f telegraf-vjk42 -n pks-system
    2020-08-10T01:03:14Z I! Starting Telegraf 1.13.2
    2020-08-10T01:03:14Z I! Using config file: /etc/telegraf/telegraf.conf
    2020-08-10T01:03:14Z I! Loaded inputs: kubernetes prometheus prometheus
    2020-08-10T01:03:14Z I! Loaded aggregators:
    2020-08-10T01:03:14Z I! Loaded processors:
    2020-08-10T01:03:14Z I! Loaded outputs: prometheus_client prometheus_client
    2020-08-10T01:03:14Z I! Tags enabled: cluster_name=my-205-01 host=b8f11b70-f931-422e-b8e8-a2419c9af5ad
    2020-08-10T01:03:14Z I! [agent] Config: Interval:10s, Quiet:false, Hostname:"b8f11b70-f931-422e-b8e8-a2419c9af5ad", Flush Interval:20s
    2020-08-10T01:03:14Z W! [inputs.prometheus] Use of deprecated configuration: 'metric_version = 1'; please update to 'metric_version = 2'
    2020-08-10T01:03:14Z W! [inputs.prometheus] Use of deprecated configuration: 'metric_version = 1'; please update to 'metric_version = 2'
    2020-08-10T01:03:14Z W! [outputs.prometheus_client] Use of deprecated configuration: metric_version = 1; please update to metric_version = 2
    2020-08-10T01:03:14Z W! [outputs.prometheus_client] Use of deprecated configuration: metric_version = 1; please update to metric_version = 2
    2020-08-10T01:03:14Z I! [outputs.prometheus_client] Listening on http://0.0.0.0:9104/metrics
    2020-08-10T01:03:14Z I! [outputs.prometheus_client] Listening on http://0.0.0.0:9113/metrics 
    
##### 09. TSDB User Scrape Config Job 등록   

    -> Opsman > Healthwatch > TSDB Configuration > Additional Scrape Config Jobs > add > Apply change(HW)
    -> targets 은 해당 클러스터의 worker 노드 
    
    job_name: mariadb-telegraf
    metrics_path: /metrics
    scheme: http
    static_configs:
      - targets:
        - "172.28.3.5:9104"
        - "172.28.3.7:9104"

##### 10. Metric 확인
    -> grafana 접속후 mysql_global_status_wsrep_cluster_size 로 확인
    
    -> Test query
    sum(mysql_global_status_wsrep_cluster_size{job="mariadb-telegraf", cluster_name="my-205-01"})/scalar(count(mysql_global_status_wsrep_cluster_size{job="mariadb-telegraf"}))
    