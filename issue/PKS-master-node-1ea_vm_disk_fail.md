##### 장애 가정 : PKS Master 노드(1대) VM내 etcd disk loss  
##### 방안 : 별도의 restore 없이 VM recreate 및 VM restart 를 통해 해결   
1) 장애시(1대노드) 현재 상태에서의 백업 수행 (복구시점 최소화를 위해)      
2) 문제가 발생한 vm recreate
3) etcd 동기화를 위한 정상 Master 노드(2대) VM restart 수행
   
##### 1. 장애 주입
    -> 특정 master node ssh 접속후 etcd 데이터 및 fluentd 설정 파일 부분 삭제
    -> Persistent 영역과 Ephemeral 영역 동시에 장애 유발
    master/9b8ad6e0-a438-4033-9767-46c586fb4771:/var/vcap/data/jobs# rm -rf fluentd
    master/9b8ad6e0-a438-4033-9767-46c586fb4771:/var/vcap/store/etcd/member/wal# rm -rf *
    master/9b8ad6e0-a438-4033-9767-46c586fb4771:/var/vcap/store/etcd/member/wal#
    
    master/9b8ad6e0-a438-4033-9767-46c586fb4771:~# monit summary
    /var/vcap/monit/job/0006_fluentd.monitrc:3: Warning: the executable does not exist '/var/vcap/jobs/fluentd/bin/ctl'
    /var/vcap/monit/job/0006_fluentd.monitrc:4: Warning: the executable does not exist '/var/vcap/jobs/fluentd/bin/ctl'
    The Monit daemon 5.2.5 uptime: 46m
    
    Process 'kube-apiserver'            running
    Process 'kube-controller-manager'   running
    Process 'kube-scheduler'            running
    Process 'etcd'                      Execution failed
    Process 'blackbox'                  running
    Process 'ncp'                       running
    Process 'fluentd'                   not monitored - restart pending
    Process 'telegraf'                  running
    Process 'bosh-dns'                  running
    Process 'bosh-dns-resolvconf'       running
    Process 'bosh-dns-healthcheck'      running
    Process 'system-metrics-agent'      running
    System 'system_localhost'           running
      
   
##### 2. 백업수행(For 최신백업)   
    -> 장애난 노드로 인해 백업 자체 에러
    -> 결국 백업은 모든 master 노드(3대)가 정상일 경우에만 수행 가능
    ubuntu@opsmgr-02:~/bbr/script$ ./bbr_pks_one_cluster_backup.sh service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    ++ date +%Y-%m-%d-%H-%M-%S
    + current_date=2020-08-05-02-21-35
    +++ dirname ./bbr_pks_one_cluster_backup.sh
    ++ cd .
    ++ pwd
    ....
    ....
    [bbr] 2020/08/05 02:22:00 INFO - Running post-backup-unlock scripts...
    [bbr] 2020/08/05 02:22:00 INFO - Finished running post-backup-unlock scripts.
    1 error occurred:
    error 1:
    1 error occurred:
    error 1:
    Error attempting to run backup for job bbr-etcd on master/9b8ad6e0-a438-4033-9767-46c586fb4771: Error: dial tcp 172.28.3.2:2379: connect: connection refused - exit code 2

##### 3. 장애노드 delete-vm 
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 delete-vm master_service-instance-56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4_dd04187297f4
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Using deployment 'service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4'
    
    Continue? [yN]: y
    
    Task 204424
    
    Task 204424 | 03:29:11 | Delete VM: master_service-instance-56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4_dd04187297f4
    Task 204424 | 03:29:39 | Delete VM: VM master_service-instance-56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4_dd04187297f4 is successfully deleted (00:00:00)
    Task 204424 | 03:29:39 | Delete VM: master_service-instance-56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4_dd04187297f4 (00:00:28)
    
    Task 204424 Started  Wed Aug  5 03:29:11 UTC 2020
    Task 204424 Finished Wed Aug  5 03:29:39 UTC 2020
    Task 204424 Duration 00:00:28
    Task 204424 done
    
    Succeeded
    
    -> 확인
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 is
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Task 204439. Done
    
    Deployment 'service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4'
    
    Instance                                           Process State  AZ       IPs         Deployment
    apply-addons/b7464878-e9c2-4c18-9f3b-89aae38f8d32  -              pks-az1  -           service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/774bfafe-67a2-406b-9ee5-a8db68f2e694        running        pks-az3  172.28.3.4  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/8cdf6298-e50a-4dc3-997b-b7e14502cc57        running        pks-az2  172.28.3.3  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/9b8ad6e0-a438-4033-9767-46c586fb4771        -              pks-az1  -           service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    worker/3b2ae3af-a4ff-4850-8d36-a120525bab4b        running        pks-az1  172.28.3.5  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    
    5 instances
    
##### 4. cck 수행
    
    -> 새로운 vm 생성을 위해 cck를 통해 기존 정보 삭제
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 cck
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Using deployment 'service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4'
    
    Task 204479
    
    Task 204479 | 03:31:18 | Scanning 4 VMs: Checking VM states (00:00:21)
    Task 204479 | 03:31:39 | Scanning 4 VMs: 3 OK, 0 unresponsive, 1 missing, 0 unbound (00:00:00)
    Task 204479 | 03:31:39 | Scanning 4 persistent disks: Looking for inactive disks (00:00:53)
    Task 204479 | 03:32:32 | Scanning 4 persistent disks: 4 OK, 0 missing, 0 inactive, 0 mount-info mismatch (00:00:00)
    
    Task 204479 Started  Wed Aug  5 03:31:18 UTC 2020
    Task 204479 Finished Wed Aug  5 03:32:32 UTC 2020
    Task 204479 Duration 00:01:14
    Task 204479 done
    
    #   Type        Description
    94  missing_vm  VM for 'master/9b8ad6e0-a438-4033-9767-46c586fb4771 (0)' missing.
    
    1 problems
    
    1: Skip for now
    2: Recreate VM without waiting for processes to start
    3: Recreate VM and wait for processes to start
    4: Delete VM reference
    VM for 'master/9b8ad6e0-a438-4033-9767-46c586fb4771 (0)' missing. (1): 4
    
    Continue? [yN]: y
    
    
    Task 204502

##### 5. 신규 VM recreate
    
    -> vm recreate 작업은 fluentd 는 정상기동, etcd는 여전히 장애
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 recreate master/9b8ad6e0-a438-4033-9767-46c586fb4771
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Using deployment 'service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4'
    
    Continue? [yN]: y
    
    Task 204518
    
    -> 확인 (두가지 장애중 fluentd 장애는 해결)
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 is --ps | grep master/9b8ad6e0-a438-4033-9767-46c586fb4771
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	-                      	failing	pks-az1	172.28.3.2	service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	blackbox               	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	bosh-dns               	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	bosh-dns-healthcheck   	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	bosh-dns-resolvconf    	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	etcd                   	unknown	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	fluentd                	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	kube-apiserver         	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	kube-controller-manager	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	kube-scheduler         	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	ncp                    	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	system-metrics-agent   	running	-      	-         	-
    master/9b8ad6e0-a438-4033-9767-46c586fb4771      	telegraf               	running	-      	-         	-
    
##### 6. etcd 장애 해결을 위한 정상노드 VM shutdown  
    -> bosh 를 통해 정상노드 vm restart 시 장애 노드에 대한 update 수행 작업으로 restart 작업이 정상적으로 진행되지 않음
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 restart  master/774bfafe-67a2-406b-9ee5-a8db68f2e694
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Using deployment 'service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4'
    
    Continue? [yN]: y
    
    Task 204847
    
    Task 204847 | 03:49:38 | Deprecation: Global 'properties' are deprecated. Please define 'properties' at the job level.
    Task 204847 | 03:49:39 | Preparing deployment: Preparing deployment (00:00:01)
    Task 204847 | 03:49:40 | Preparing deployment: Rendering templates (00:00:11)
    Task 204847 | 03:49:52 | Preparing package compilation: Finding packages to compile (00:00:00)
    Task 204847 | 03:49:53 | Updating instance master: master/9b8ad6e0-a438-4033-9767-46c586fb4771 (0) (canary) 
    
    -> 즉각적인 VM restart를 위해 vCenter 접속 후 정상인 노드 한대씩 stop 수행
    -> 모든 master 노드 비정상
    ubuntu@opsmgr-02:~$ bosh -d service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4 is
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Task 204937. Done
    
    Deployment 'service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4'
    
    Instance                                           Process State       AZ       IPs         Deployment
    apply-addons/b7464878-e9c2-4c18-9f3b-89aae38f8d32  -                   pks-az1  -           service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/774bfafe-67a2-406b-9ee5-a8db68f2e694        unresponsive agent  pks-az3  172.28.3.4  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/8cdf6298-e50a-4dc3-997b-b7e14502cc57        unresponsive agent  pks-az2  172.28.3.3  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    master/9b8ad6e0-a438-4033-9767-46c586fb4771        failing             pks-az1  172.28.3.2  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    worker/3b2ae3af-a4ff-4850-8d36-a120525bab4b        running             pks-az1  172.28.3.5  service-instance_56c19cfc-d5d7-4e11-aee2-78c81f4e7ad4
    
    5 instances
    
    Succeeded
    
    -> All Master 노드 비정상이나 서비스 자체는 정상 (nginx LB 접속 테스트)
    ubuntu@opsmgr-02:~$ curl 10.195.70.159
    <!DOCTYPE html>
    <html>
    <head>
    <title>Welcome to nginx!</title>
    <style>
        body {
            width: 35em;
            margin: 0 auto;
            font-family: Tahoma, Verdana, Arial, sans-serif;
        }
    </style>
    </head>
    <body>
    <h1>Welcome to nginx!</h1>
    <p>If you see this page, the nginx web server is successfully installed and
    working. Further configuration is required.</p>
    
    <p>For online documentation and support please refer to
    <a href="http://nginx.org/">nginx.org</a>.<br/>
    Commercial support is available at
    <a href="http://nginx.com/">nginx.com</a>.</p>
    
    <p><em>Thank you for using nginx.</em></p>
    </body>
    </html>

##### 7. 정상노드 VM power on
    
    -> vCenter 에서 해당 노드 VM CID 확인을 통해 Power On 수행