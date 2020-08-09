
##### PKS Cluster Master노드내 etcd 데이터 corruption 발생 가정   


##### 01. Master node 접근   
    ubuntu@opsmgr-02-haas-252-pez-pivotal-i:~/yaml/cafe$ bosh -d service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df ssh master/5f5eb080-c238-4e81-8073-ecc63ce98cee
    Using environment '172.16.1.11' as client 'ops_manager'

    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# monit summary
    The Monit daemon 5.2.5 uptime: 17h 13m
    
    Process 'kube-apiserver'            running
    Process 'kube-controller-manager'   running
    Process 'kube-scheduler'            running
    Process 'etcd'                      running
    Process 'blackbox'                  running
    Process 'ncp'                       running
    Process 'telegraf'                  running
    Process 'node_exporter'             running
    Process 'bosh-dns'                  running
    Process 'bosh-dns-resolvconf'       running
    Process 'bosh-dns-healthcheck'      running
    Process 'system-metrics-agent'      running
    System 'system_localhost'           running
    
##### 02. 장애를 일으킴 ( /var/vcap/store/etcd 내 데이터 모두 삭제)   
    -> etcd stop
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# monit stop etcd
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd#
    
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# ls -lrt
    total 4
    drwx------ 4 vcap vcap 4096 Aug  8 09:11 member
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# rm -rf *
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# ls
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd#
    
    -> 장애 확인
    Deployment 'service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df'
    
    Instance                                     Process State  AZ       IPs         VM CID                                   VM Type      Active  Stemcell
    master/377482a0-4687-4b97-82d5-670dac2ed94e  running        pks-az2  172.28.3.3  vm-ff6d9ed5-5dea-4e39-ba8c-9b27b4577762  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.76
    master/59e3f363-85b7-4f5b-b824-643f025eccd5  running        pks-az1  172.28.3.2  vm-2089c14b-629f-4b3e-9f9e-9d8cc2ffd93b  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.76
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee  failing        pks-az3  172.28.3.4  vm-a9a39796-f2d1-4326-8247-e3468eef43ad  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.76
    worker/2ffa96c5-dc5c-4498-a13f-98ccdaf4f690  running        pks-az1  172.28.3.5  vm-5e5960cb-2181-42c4-94db-fe7869844d0d  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.76
    
    4 vms
    
    -> 에러 확인
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# tail -f /var/vcap/sys/log/etcd/etcd.stderr.log
    Error: etcdserver: unhealthy cluster 
    Error: etcdserver: unhealthy cluster

##### 03. 장애처리 1 : remove node   

    -> etcd stop
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# monit stop etcd
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# ls
       
    -> etcd cluster 확인 (etcd API는 verion 3로 사용)
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# ETCDCTL_API=3 /var/vcap/jobs/etcd/bin/etcdctl member list
    18ac61d8503c2eb, started, 5f5eb080-c238-4e81-8073-ecc63ce98cee, https://master-2.etcd.cfcr.internal:2380, https://master-2.etcd.cfcr.internal:2379
    17f206fd866fdab2, started, 59e3f363-85b7-4f5b-b824-643f025eccd5, https://master-0.etcd.cfcr.internal:2380, https://master-0.etcd.cfcr.internal:2379
    65475fb7f7c6df9d, started, 377482a0-4687-4b97-82d5-670dac2ed94e, https://master-1.etcd.cfcr.internal:2380, https://master-1.etcd.cfcr.internal:2379
    
    -> remove member (장애난 노드)
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# export ETCDCTL_API=3
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# etcdctl member remove 18ac61d8503c2eb
    Member  18ac61d8503c2eb removed from cluster 6d938e3be5102340
    
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# etcdctl member list
    17f206fd866fdab2, started, 59e3f363-85b7-4f5b-b824-643f025eccd5, https://master-0.etcd.cfcr.internal:2380, https://master-0.etcd.cfcr.internal:2379
    65475fb7f7c6df9d, started, 377482a0-4687-4b97-82d5-670dac2ed94e, https://master-1.etcd.cfcr.internal:2380, https://master-1.etcd.cfcr.internal:2379
   
##### 03. 장애처리 2 : add node
    
    -> 데이터 복구를 위한 저장소 재생성
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# mkdir -p /var/vcap/store/etcd/member
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd#
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# chown vcap:vcap /var/vcap/store/etcd/member
    
    -> etcd member 조인을 위한 환경변수 확인
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# cat /var/vcap/jobs/etcd/bin/utils.sh
    
    etcd_endpoint_address="https://master-2.etcd.cfcr.internal:2379"
    etcd_endpoints="https://master-0.etcd.cfcr.internal:2379,https://master-1.etcd.cfcr.internal:2379,https://master-2.etcd.cfcr.internal:2379"
    
    etcd_peer_address="https://master-2.etcd.cfcr.internal:2380"
    etcd_peers="59e3f363-85b7-4f5b-b824-643f025eccd5=https://master-0.etcd.cfcr.internal:2380,377482a0-4687-4b97-82d5-670dac2ed94e=https://master-1.etcd.cfcr.internal:2380,5f5eb080-c238-4e81-8073-ecc63ce98cee=https://master-2.etcd.cfcr.internal:2380"       
    
    -> 환경변수 설정
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# source /var/vcap/jobs/etcd/bin/utils.sh
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd# echo $etcd_endpoint_address
    https://master-2.etcd.cfcr.internal:2379
    
    -> member add 
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd/member# etcdctl member add 5f5eb080-c238-4e81-8073-ecc63ce98cee --peer-urls ${etcd_peer_address}
    Member 790dc8e1c66b89a3 added to cluster 6d938e3be5102340
    
    ETCD_NAME="5f5eb080-c238-4e81-8073-ecc63ce98cee"
    ETCD_INITIAL_CLUSTER="59e3f363-85b7-4f5b-b824-643f025eccd5=https://master-0.etcd.cfcr.internal:2380,377482a0-4687-4b97-82d5-670dac2ed94e=https://master-1.etcd.cfcr.internal:2380,5f5eb080-c238-4e81-8073-ecc63ce98cee=https://master-2.etcd.cfcr.internal:2380"
    ETCD_INITIAL_ADVERTISE_PEER_URLS="https://master-2.etcd.cfcr.internal:2380"
    ETCD_INITIAL_CLUSTER_STATE="existing"
    
    -> 확인
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd/member# etcdctl member list
    17f206fd866fdab2, started, 59e3f363-85b7-4f5b-b824-643f025eccd5, https://master-0.etcd.cfcr.internal:2380, https://master-0.etcd.cfcr.internal:2379
    65475fb7f7c6df9d, started, 377482a0-4687-4b97-82d5-670dac2ed94e, https://master-1.etcd.cfcr.internal:2380, https://master-1.etcd.cfcr.internal:2379
    790dc8e1c66b89a3, unstarted, , https://master-2.etcd.cfcr.internal:2380,
    
##### 03. 장애처리 3 : 신규 etcd node start 및 확인

    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd/member# monit start etcd
    
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd/member# etcdctl member list
    17f206fd866fdab2, started, 59e3f363-85b7-4f5b-b824-643f025eccd5, https://master-0.etcd.cfcr.internal:2380, https://master-0.etcd.cfcr.internal:2379
    65475fb7f7c6df9d, started, 377482a0-4687-4b97-82d5-670dac2ed94e, https://master-1.etcd.cfcr.internal:2380, https://master-1.etcd.cfcr.internal:2379
    790dc8e1c66b89a3, started, 5f5eb080-c238-4e81-8073-ecc63ce98cee, https://master-2.etcd.cfcr.internal:2380, https://master-2.etcd.cfcr.internal:2379
    
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee:/var/vcap/store/etcd/member# etcdctl endpoint status -w table
    +------------------------------------------+------------------+---------+---------+-----------+-----------+------------+
    |                 ENDPOINT                 |        ID        | VERSION | DB SIZE | IS LEADER | RAFT TERM | RAFT INDEX |
    +------------------------------------------+------------------+---------+---------+-----------+-----------+------------+
    | https://master-0.etcd.cfcr.internal:2379 | 17f206fd866fdab2 |  3.3.17 |  2.6 MB |     false |         4 |     144615 |
    | https://master-1.etcd.cfcr.internal:2379 | 65475fb7f7c6df9d |  3.3.17 |  2.6 MB |      true |         4 |     144616 |
    | https://master-2.etcd.cfcr.internal:2379 | 790dc8e1c66b89a3 |  3.3.17 |  2.6 MB |     false |         4 |     144616 |
    +------------------------------------------+------------------+---------+---------+-----------+-----------+------------+
    
    ubuntu@opsmgr-02-haas-252-pez-pivotal-i:~$ bosh -d service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df is
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Task 83546. Done
    
    Deployment 'service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df'
    
    Instance                                           Process State  AZ       IPs         Deployment
    apply-addons/98a4a173-a89b-43f9-8f4d-fce5184b1dc1  -              pks-az1  -           service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df
    master/377482a0-4687-4b97-82d5-670dac2ed94e        running        pks-az2  172.28.3.3  service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df
    master/59e3f363-85b7-4f5b-b824-643f025eccd5        running        pks-az1  172.28.3.2  service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df
    master/5f5eb080-c238-4e81-8073-ecc63ce98cee        running        pks-az3  172.28.3.4  service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df
    worker/2ffa96c5-dc5c-4498-a13f-98ccdaf4f690        running        pks-az1  172.28.3.5  service-instance_ad44b0a0-3b8b-4fb6-9baf-7df22d65f2df
    
    5 instances
    
    Succeeded
       
      