##### 목표 : VM recreation 을 통해 별도의 bbr restore 없이 Ephemeral 영역 복구     
##### 방법 : bosh cck를 통한 VM recreation   


##### 1. 해당 VM 내 장애 주입   
    master/5cc5762c-9f12-4065-8d76-1a6593ff59bc:/var/vcap/data/jobs# ls -lrt
    total 88
    .....
    drwxr-x--- 3 root vcap 4096 Aug  2 23:24 bbr-kube-apiserver
    drwxr-x--- 3 root vcap 4096 Aug  2 23:24 ncp
    drwxr-x--- 3 root vcap 4096 Aug  2 23:24 pks-nsx-t-ncp
    drwxr-x--- 3 root vcap 4096 Aug  2 23:24 pks-nsx-t-prepare-master-vm
    drwxr-x--- 3 root vcap 4096 Aug  2 23:24 fluentd
    drwxr-x--- 3 root vcap 4096 Aug  2 23:24 telemetry-agent
    ....
    master/5cc5762c-9f12-4065-8d76-1a6593ff59bc:/var/vcap/data/jobs#
    master/5cc5762c-9f12-4065-8d76-1a6593ff59bc:/var/vcap/data/jobs# rm -rf fluentd/
    
##### 2. 장애 주입에 따른 VM 확인   
    ubuntu@opsmgr-02:~$ bosh vms
    Using environment '172.16.1.11' as client 'ops_manager'
    Deployment 'service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc'
    
    Instance                                     Process State  AZ       IPs         VM CID                                                                     VM Type      Active  Stemcell
    master/5cc5762c-9f12-4065-8d76-1a6593ff59bc  failing        pks-az1  172.28.4.2  master_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_5da56767dc2f  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
    worker/7d1593e3-281f-48a6-b9d9-d51227bb0c08  running        pks-az1  172.28.4.3  worker_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_c9e2e938f3f7  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
    worker/ce258162-22dc-4cce-a594-cd43dae59f0e  running        pks-az2  172.28.4.4  worker_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_59cd4aef0977  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
    
##### 3. 해당 VM 삭제   
    ubuntu@opsmgr-02:~$ bosh -d service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc delete-vm master_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_5da56767dc2f
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Using deployment 'service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc'
    
    Continue? [yN]: y
    
    Task 198423
    
    Task 198423 | 09:41:07 | Delete VM: master_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_5da56767dc2f
    Task 198423 | 09:41:37 | Delete VM: VM master_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_5da56767dc2f is successfully deleted (00:00:00)
    Task 198423 | 09:41:37 | Delete VM: master_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_5da56767dc2f (00:00:30)
    
    Task 198423 Started  Tue Aug  4 09:41:07 UTC 2020
    Task 198423 Finished Tue Aug  4 09:41:37 UTC 2020
    Task 198423 Duration 00:00:30
    Task 198423 done
    
    Succeeded    
    
##### 4. bosh cck 수행   
    ubuntu@opsmgr-02:~$ bosh -d service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc cck
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Using deployment 'service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc'
    
    Task 198434
    
    Task 198434 | 09:42:22 | Scanning 3 VMs: Checking VM states (00:00:21)
    Task 198434 | 09:42:43 | Scanning 3 VMs: 2 OK, 0 unresponsive, 1 missing, 0 unbound (00:00:00)
    Task 198434 | 09:42:43 | Scanning 3 persistent disks: Looking for inactive disks (00:00:39)
    Task 198434 | 09:43:22 | Scanning 3 persistent disks: 3 OK, 0 missing, 0 inactive, 0 mount-info mismatch (00:00:00)
    
    Task 198434 Started  Tue Aug  4 09:42:22 UTC 2020
    Task 198434 Finished Tue Aug  4 09:43:22 UTC 2020
    Task 198434 Duration 00:01:00
    Task 198434 done
    
    #   Type        Description
    87  missing_vm  VM for 'master/5cc5762c-9f12-4065-8d76-1a6593ff59bc (0)' missing.
    
    1 problems
    
    1: Skip for now
    2: Recreate VM without waiting for processes to start
    3: Recreate VM and wait for processes to start
    4: Delete VM reference
    VM for 'master/5cc5762c-9f12-4065-8d76-1a6593ff59bc (0)' missing. (1): 3
    
    Continue? [yN]: y

##### 5. cck 수행에 따른 프로세스 확인  
    ubuntu@opsmgr-02:~$ bosh tasks
    Using environment '172.16.1.11' as client 'ops_manager'
    
    ID      State       Started At                    Finished At  User         Deployment                                             Description        Result
    198440  processing  Tue Aug  4 09:43:48 UTC 2020  -            ops_manager  service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc  apply resolutions  -
    
    1 tasks
    
    Succeeded
    
##### 6. 결과 확인   
    
    Deployment 'service-instance_219891a3-e32d-4906-9782-1f7b5cd78abc'
    
    Instance                                     Process State  AZ       IPs         VM CID                                                                     VM Type      Active  Stemcell
    master/5cc5762c-9f12-4065-8d76-1a6593ff59bc  running        pks-az1  172.28.4.2  master_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_90afdcf066b7  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
    worker/7d1593e3-281f-48a6-b9d9-d51227bb0c08  running        pks-az1  172.28.4.3  worker_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_c9e2e938f3f7  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
    worker/ce258162-22dc-4cce-a594-cd43dae59f0e  running        pks-az2  172.28.4.4  worker_service-instance-219891a3-e32d-4906-9782-1f7b5cd78abc_59cd4aef0977  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
    