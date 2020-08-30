##### 01. wordpress Helm Chart deploy      

    ubuntu@opsmgr-02:~$ mkdir bitnami-wordpress
    ubuntu@opsmgr-02:~$ cd bitnami-wordpress/
    ubuntu@opsmgr-02:~/bitnami-wordpress$ ls
    ubuntu@opsmgr-02:~/bitnami-wordpress$ ls -lrt
    
    ubuntu@opsmgr-02:~/bitnami-wordpress$ helm repo add bitnami https://charts.bitnami.com/bitnami
    "bitnami" has been added to your repositories
    ubuntu@opsmgr-02:~/bitnami-wordpress$ helm fetch bitnami/wordpress
    ubuntu@opsmgr-02:~/bitnami-wordpress$ ls -lrt
    total 52
    -rw-rw-r-- 1 ubuntu ubuntu    99 Aug 30 08:19 README
    -rw-r--r-- 1 ubuntu ubuntu 47887 Aug 30 08:20 wordpress-9.5.1.tgz
    
    ubuntu@opsmgr-02:~/bitnami-wordpress$ tar xvfz wordpress-9.5.1.tgz
    wordpress/Chart.yaml
    wordpress/values.yaml
    wordpress/templates/NOTES.txt
    
    -> edit metric, storageClass
    ubuntu@opsmgr-02:~/bitnami-wordpress/wordpress$ cp values.yaml custom-values.yaml
    ubuntu@opsmgr-02:~/bitnami-wordpress/wordpress$ vi custom-values.yaml
    
    ubuntu@opsmgr-02:~/bitnami-wordpress/wordpress$ helm install wordpress -f custom-values.yaml ./
    NAME: wordpress
    LAST DEPLOYED: Sun Aug 30 08:24:27 2020
    NAMESPACE: default
    STATUS: deployed
    REVISION: 1
    NOTES:
    ** Please be patient while the chart is being deployed **
    
    ubuntu@opsmgr-02:~/bitnami-wordpress/wordpress$ kubectl get po
    NAME                         READY   STATUS    RESTARTS   AGE
    mariadb-galera-0             2/2     Running   0          50m
    mariadb-galera-1             2/2     Running   0          49m
    mariadb-galera-2             2/2     Running   0          48m
    wordpress-6576998b9b-288lt   2/2     Running   0          10m
    wordpress-mariadb-0          1/1     Running   0          10m
    
##### 02. make ClusterIP
    ubuntu@opsmgr-02:~/bitnami-wordpress/wordpress$ kubectl expose deploy wordpress --type=ClusterIP --name=wordpress-svc
    service/wordpress-svc exposed
    
    ubuntu@opsmgr-02:~/bitnami-wordpress/wordpress$ kubectl get svc
    NAME                      TYPE           CLUSTER-IP       EXTERNAL-IP     PORT(S)                                     AGE
    kubernetes                ClusterIP      10.100.200.1     <none>          443/TCP                                     28h
    mariadb-galera            ClusterIP      10.100.200.75    <none>          3306/TCP                                    63m
    mariadb-galera-headless   ClusterIP      None             <none>          4567/TCP,4568/TCP,4444/TCP                  63m
    mariadb-galera-metrics    ClusterIP      10.100.200.226   <none>          9104/TCP                                    63m
    wordpress                 LoadBalancer   10.100.200.44    10.195.70.192   80:32137/TCP,443:30563/TCP,9117:31897/TCP   24m
    wordpress-mariadb         ClusterIP      10.100.200.143   <none>          3306/TCP                                    24m
    wordpress-svc             ClusterIP      10.100.200.230   <none>          8080/TCP,8443/TCP,9117/TCP                  11s
    
##### 03. ClusterMetricSink Create  
    ubuntu@opsmgr-02:~/sink$ cat wordpress-cluster-metric-sink.yml
    apiVersion: pksapi.io/v1beta1
    kind: ClusterMetricSink
    metadata:
      name: wordpress-cluster-metric-sink
    spec:
      inputs:
      - type: prometheus
        urls:
        - "http://wordpress-svc.default:9117/metrics"
    
      outputs:
      - type: prometheus_client
        listen: ":9117"
    ubuntu@opsmgr-02:~/sink$
    
    ubuntu@opsmgr-02:~/sink$ kubectl apply -f wordpress-cluster-metric-sink.yml -n pks-system
    clustermetricsink.pksapi.io/wordpress-cluster-metric-sink created
    
    ubuntu@opsmgr-02:~/sink$ kubectl get clustermetricsink
    NAME                            AGE
    mariadb-cluster-metric-sink     11s
    nginx-cluster-metric-sink       3h27m
    wordpress-cluster-metric-sink   11s
    
    ubuntu@opsmgr-02:~/sink$ kubectl logs -f telegraf-9fxrw -n pks-system
    2020-08-30T08:54:46Z I! Starting Telegraf 1.13.2
    2020-08-30T08:54:46Z I! Using config file: /etc/telegraf/telegraf.conf
    2020-08-30T08:54:46Z I! Loaded inputs: kubernetes prometheus prometheus prometheus
    2020-08-30T08:54:46Z I! Loaded aggregators:
    2020-08-30T08:54:46Z I! Loaded processors:
    2020-08-30T08:54:46Z I! Loaded outputs: prometheus_client prometheus_client prometheus_client
    2020-08-30T08:54:46Z I! Tags enabled: cluster_name=my-205-01 host=d89d6551-64ec-4e75-a1ff-1c335b4a73fb
    2020-08-30T08:54:46Z I! [agent] Config: Interval:10s, Quiet:false, Hostname:"d89d6551-64ec-4e75-a1ff-1c335b4a73fb", Flush Interval:20s
    2020-08-30T08:54:46Z W! [inputs.prometheus] Use of deprecated configuration: 'metric_version = 1'; please update to 'metric_version = 2'
    2020-08-30T08:54:46Z W! [inputs.prometheus] Use of deprecated configuration: 'metric_version = 1'; please update to 'metric_version = 2'
    2020-08-30T08:54:46Z W! [inputs.prometheus] Use of deprecated configuration: 'metric_version = 1'; please update to 'metric_version = 2'
    2020-08-30T08:54:46Z W! [outputs.prometheus_client] Use of deprecated configuration: metric_version = 1; please update to metric_version = 2
    2020-08-30T08:54:46Z W! [outputs.prometheus_client] Use of deprecated configuration: metric_version = 1; please update to metric_version = 2
    2020-08-30T08:54:46Z W! [outputs.prometheus_client] Use of deprecated configuration: metric_version = 1; please update to metric_version = 2
    2020-08-30T08:54:46Z I! [outputs.prometheus_client] Listening on http://0.0.0.0:9113/metrics
    2020-08-30T08:54:46Z I! [outputs.prometheus_client] Listening on http://0.0.0.0:9104/metrics
    2020-08-30T08:54:46Z I! [outputs.prometheus_client] Listening on http://0.0.0.0:9117/metrics
    
##### 04. TSDB configuration   
    Opsman > Healthwatch > TSDB Configuration > TSDB configuration > add > apply Changes
    
    job_name: cluster_worker_wordpress_telegraf
    metrics_path: "/metrics"
    scheme: http
    dns_sd_configs:
      - names:
          - q-s4.worker.*.*.bosh.
        type: A
        port: 9117

##### 05. Grafana Metric check
    sum(apache_cpuload{cluster_name="my-205-01", job="cluster_worker_wordpress_telegraf"})/scalar(count(apache_cpuload{cluster_name="my-205-01", job="cluster_worker_wordpress_telegraf"}))
    

##### 06. Test by ab Tool
    # apt-get install apache2-utils
    
    ubuntu@opsmgr-02:~/bitnami-wordpress$ ab -n 10000 -c 200  http://10.195.70.192:80/
    This is ApacheBench, Version 2.3 <$Revision: 1706008 $>
    Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
    Licensed to The Apache Software Foundation, http://www.apache.org/
    
    Benchmarking 10.195.70.192 (be patient)
    Completed 1000 requests
    Completed 2000 requests
    Completed 3000 requests
    Completed 4000 requests
    Completed 5000 requests
    Completed 6000 requests
    Completed 7000 requests
    Completed 8000 requests
    Completed 9000 requests
    Completed 10000 requests
    Finished 10000 requests
    .....
    Percentage of the requests served within a certain time (ms)
      50%    807
      66%   3203
      75%   4396
      80%   4859
      90%   6525
      95%   8610
      98%  17628
      99%  19246
     100%  41674 (longest request)

    
    
    