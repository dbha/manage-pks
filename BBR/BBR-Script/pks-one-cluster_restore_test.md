##### VM Disk Remove 

##### 테스트 과정
##### 0. 해당 클러스터 백업 수행   
    ubuntu@opsmgr-02:~/bbr/script$ ./bbr_pks_one_cluster_backup.sh service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4
    ++ date +%Y-%m-%d-%H-%M-%S
    + current_date=2020-08-03-10-46-40
    +++ dirname ./bbr_pks_one_cluster_backup.sh
    ++ cd .
    ++ pwd
    + WORK_DIR=/home/ubuntu/bbr/script
    + om --env /home/ubuntu/bbr/script/env.yml bosh-env
    + source /home/ubuntu/bbr/script/bosh-env.sh
    ++ export BOSH_CLIENT_SECRET=xxxxx
    ++ BOSH_CLIENT_SECRET=xxxxx
    ++ export BOSH_ENVIRONMENT=172.16.1.11
    ++ BOSH_ENVIRONMENT=172.16.1.11
    ++ export 'BOSH_CA_CERT=-----BEGIN CERTIFICATE-----
    ....
    + bbr deployment --deployment service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4 --target 172.16.1.11 --username pivotal-container-service-d7cde469951aa96aa1f5 --ca-cert /home/ubuntu/bbr/script/bosh_ca.crt backup-cleanup
    [bbr] 2020/08/03 10:46:41 INFO - Looking for scripts
    [bbr] 2020/08/03 10:46:46 INFO - master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d/bbr-etcd/backup
    [bbr] 2020/08/03 10:46:46 INFO - master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d/bbr-etcd/metadata
    [bbr] 2020/08/03 10:46:46 INFO - master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d/bbr-etcd/post-re
    [bbr] 2020/08/03 10:47:04 INFO - Finished validity checks -- for job bbr-etcd-cfcr-etcd-backup-one-restore-all on master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d...
    [bbr] 2020/08/03 10:47:04 INFO - Backup created of service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4 on 2020-08-03 10:47:04.427915473 +0000 UTC m=+9.213325686
    .....
    ubuntu@opsmgr-02:~/bbr/script$ ls -lrt
    -rw-rw-r-- 1 ubuntu ubuntu   309251 Aug  3 10:47 172.16.1.11_pks_one_cluster-backup_2020-08-03-10-46-40.tgz

##### 1. 3master 중 2개의 마스터 VM 삭제 (삭제전 bosh update-resurrection off)   
      -> 삭제는 vCenter 에서 Delete from disk 방식
      
##### 2. 삭제후 bosh 를 통한 결과 확인   
      -> 두개 마스터 VM에 대한 정보가 없어짐
      
      ubuntu@opsmgr-02:~/bbr/script$ bosh vms
      Using environment '172.16.1.11' as client 'ops_manager'
      Task 192850
      Task 192853
      Task 192852
      Task 192854
      Task 192851
      Task 192850 done 
      
      Deployment 'service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4'
      
      Instance                                     Process State       AZ       IPs         VM CID                                                                     VM Type      Active  Stemcell
      master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d  unresponsive agent  pks-az1  172.28.1.2  master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_09e121874167  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      master/da283145-4cfa-4e32-bdeb-3f6d30567a63  unresponsive agent  pks-az3  172.28.1.4  master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_0ccb9f7d5614  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      master/ecff0115-bf02-43d9-93d8-78e43ae2e346  running             pks-az2  172.28.1.3  master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_a5af93838a99  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      worker/cf006040-b514-4157-8dc6-09820c078ac7  running             pks-az1  172.28.1.5  worker_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_a1d0b8fc14e4  xlarge       true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71 

##### 3. 복구전 cloud-check를 통해 orphaned 돤 VM 및 Disk reference 삭제 
      ubuntu@opsmgr-02:~/bbr/script$ bosh -d service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4 cloud-check
      Using environment '172.16.1.11' as client 'ops_manager'
      
      Using deployment 'service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4'
      
      Task 192929
      
      Task 192929 | 11:00:46 | Scanning 4 VMs: Checking VM states (00:00:42)
      Task 192929 | 11:01:28 | Scanning 4 VMs: 1 OK, 1 unresponsive, 2 missing, 0 unbound (00:00:00)
      Task 192929 | 11:01:28 | Scanning 4 persistent disks: Looking for inactive disks (00:00:44)
      Task 192929 | 11:02:12 | Scanning 4 persistent disks: 2 OK, 2 missing, 0 inactive, 0 mount-info mismatch (00:00:00)
      
      #   Type                Description
      68  missing_vm          VM for 'master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d (0)' with cloud ID 'master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_09e121874167' missing.
      69  missing_vm          VM for 'master/da283145-4cfa-4e32-bdeb-3f6d30567a63 (2)' with cloud ID 'master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_0ccb9f7d5614' missing.
      70  unresponsive_agent  VM for 'master/ecff0115-bf02-43d9-93d8-78e43ae2e346 (1)' with cloud ID 'master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_a5af93838a99' is not responding.
      71  missing_disk        Disk 'disk-5b7f905a-a79c-4ec4-8c2b-67d1e2479e2c' (master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d, 10240M) is missing
      72  missing_disk        Disk 'disk-0c682741-0342-4935-a9bb-640040512919' (master/da283145-4cfa-4e32-bdeb-3f6d30567a63, 10240M) is missing
      
      5 problems
      
      1: Skip for now
      2: Recreate VM without waiting for processes to start
      3: Recreate VM and wait for processes to start
      4: Delete VM reference
      VM for 'master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d (0)' with cloud ID 'master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_09e121874167' missing. (1): 4
      
      1: Skip for now
      2: Recreate VM without waiting for processes to start
      3: Recreate VM and wait for processes to start
      4: Delete VM reference
      VM for 'master/da283145-4cfa-4e32-bdeb-3f6d30567a63 (2)' with cloud ID 'master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_0ccb9f7d5614' missing. (1): 4
      
      1: Skip for now
      2: Reboot VM
      3: Recreate VM without waiting for processes to start
      4: Recreate VM and wait for processes to start
      5: Delete VM
      6: Delete VM reference (forceful; may need to manually delete VM from the Cloud to avoid IP conflicts)
      VM for 'master/ecff0115-bf02-43d9-93d8-78e43ae2e346 (1)' with cloud ID 'master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_a5af93838a99' is not responding. (1): 1
      .......
      
##### 4. bosh deploy를 통해 2개의 master VM redeploy 수행  
      -> recreate 중 에러 발생 

      ubuntu@opsmgr-02:~/bbr/script/service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4_20200803T104655Z$ bosh deploy -d service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4 ./manifest.yml --recreate-persistent-disks --recreate
      Using environment '172.16.1.11' as client 'ops_manager'
      
      Using deployment 'service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4'
      
      Continue? [yN]: y
      
      Task 192958

      Task 192958 | 11:06:59 | Deprecation: Global 'properties' are deprecated. Please define 'properties' at the job level.
      Task 192958 | 11:07:00 | Preparing deployment: Preparing deployment
      
       (00:02:16)
                            L Error: master/ecff0115-bf02-43d9-93d8-78e43ae2e346: Timed out sending 'get_state' to instance: 'master/ecff0115-bf02-43d9-93d8-78e43ae2e346', agent-id: '7a479651-c7ec-4397-8032-ca83ba39c4ca' after 45 seconds
      Task 192958 | 11:09:16 | Error: master/ecff0115-bf02-43d9-93d8-78e43ae2e346: Timed out sending 'get_state' to instance: 'master/ecff0115-bf02-43d9-93d8-78e43ae2e346', agent-id: '7a479651-c7ec-4397-8032-ca83ba39c4ca' after 45 seconds
      
      Task 192958 Started  Mon Aug  3 11:06:59 UTC 2020
      Task 192958 Finished Mon Aug  3 11:09:16 UTC 2020
      Task 192958 Duration 00:02:17
      Task 192958 error
      
      Updating deployment:
        Expected task '192958' to succeed but state is 'error'
      
      Exit code 1       

##### 5. vCenter에서 살아있는 나머지 한개의 vm 역시 삭제
      -> 삭제는 vCenter 에서 Delete from disk 방식
      
##### 6. redeploy 작업 다시 수행   
      -> 마스터 vm deploy 성공
      ubuntu@opsmgr-02:~/bbr/script/service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4_20200803T104655Z$ bosh deploy -d service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4 ./manifest.yml --recreate-persistent-disks --recreate
      Using environment '172.16.1.11' as client 'ops_manager'
      
      Using deployment 'service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4'
      
      Continue? [yN]: y
      
      Task 193008
      
      Task 193008 | 11:13:07 | Deprecation: Global 'properties' are deprecated. Please define 'properties' at the job level.
      Task 193008 | 11:13:08 | Preparing deployment: Preparing deployment
      Task 193008 | 11:13:09 | Warning: DNS address not available for the link provider instance: pivotal-container-service/11af0d47-48e3-4871-9b44-28c5b587df59
      Task 193008 | 11:13:09 | Warning: DNS address not available for the link provider instance: pivotal-container-service/11af0d47-48e3-4871-9b44-28c5b587df59
      Task 193008 | 11:13:09 | Warning: DNS address not available for the link provider instance: pivotal-container-service/11af0d47-48e3-4871-9b44-28c5b587df59
      
      
      Task 193008 | 11:13:25 | Preparing deployment: Preparing deployment (00:00:17)
      Task 193008 | 11:13:25 | Preparing deployment: Rendering templates (00:00:12)
      Task 193008 | 11:13:37 | Preparing package compilation: Finding packages to compile (00:00:00)
      Task 193008 | 11:13:37 | Creating missing vms: master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d (0)
      Task 193008 | 11:13:37 | Creating missing vms: master/da283145-4cfa-4e32-bdeb-3f6d30567a63 (2)
      Task 193008 | 11:13:37 | Creating missing vms: master/ecff0115-bf02-43d9-93d8-78e43ae2e346 (1)
      .....
      Task 193008 Started  Mon Aug  3 11:13:07 UTC 2020
      Task 193008 Finished Mon Aug  3 11:35:12 UTC 2020
      Task 193008 Duration 00:22:05
      Task 193008 done
      
      Succeeded   
      
      ubuntu@opsmgr-02:~/bbr/script$ bosh vms
      Using environment '172.16.1.11' as client 'ops_manager'
      
      Task 193481
      Task 193483
      Task 193482
      Task 193484
      Task 193485
      ....
      Deployment 'service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4'
      
      Instance                                     Process State  AZ       IPs         VM CID                                                                     VM Type      Active  Stemcell
      master/573a1e38-6c38-4c8c-9a38-86fbd2094e6d  running        pks-az1  172.28.1.2  master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_7e863fbde433  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      master/da283145-4cfa-4e32-bdeb-3f6d30567a63  running        pks-az3  172.28.1.4  master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_2c80baa43569  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      master/ecff0115-bf02-43d9-93d8-78e43ae2e346  running        pks-az2  172.28.1.3  master_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_ec878d3efc6c  medium.disk  true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      worker/cf006040-b514-4157-8dc6-09820c078ac7  running        pks-az1  172.28.1.5  worker_service-instance-a00ab0df-8867-4e01-8a5c-87cc44ce65d4_17da3466bde8  xlarge       true    bosh-vsphere-esxi-ubuntu-xenial-go_agent/621.71
      
      4 vms
      
##### 7. Master 3대 노드 VM deploy후 상태 확인  
      -> 아무것도 없는 K8s 초기상태
      
      ubuntu@opsmgr-02:~/bbr/script$ pks get-credentials my-205-01
      
      Fetching credentials for cluster my-205-01.
      Context set for cluster my-205-01.
      
      You can now switch between clusters by using:
      $kubectl config use-context <cluster-name>
      
      ubuntu@opsmgr-02:~/bbr/script$ kubectl get po
      No resources found in default namespace.
      
      ubuntu@opsmgr-02:~/bbr/script$ kubectl get po -A
      No resources found
      
      ubuntu@opsmgr-02:~/bbr/script$ kubectl get ns
      NAME              STATUS   AGE
      default           Active   20m
      kube-node-lease   Active   20m
      kube-public       Active   20m
      kube-system       Active   20m
      
      ubuntu@opsmgr-02:~/bbr/script$ kubectl get cs
      NAME                 AGE
      scheduler            <unknown>
      controller-manager   <unknown>
      etcd-2               <unknown>
      etcd-0               <unknown>
      etcd-1               <unknown>   
      
 ##### 8. bbr restore를 통해 클러스터 복구   
      ubuntu@opsmgr-02:~/bbr/script$ ./bbr_pks_one_cluster_restore.sh service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4 service-instance_a00ab0df-8867-4e01-8a5c-87cc44ce65d4_20200803T104655Z
      nohup: ignoring input and appending output to 'nohup.out'
      
      ubuntu@opsmgr-02:~/bbr/script$
      
      ubuntu@opsmgr-02:~/bbr/script$ kubectl get po -A
      NAMESPACE     NAME                                                            READY   STATUS      RESTARTS   AGE
      kube-system   coredns-5b6649768f-rlfrj                                        1/1     Running     0          61m
      kube-system   coredns-5b6649768f-sj6qw                                        1/1     Running     0          61m
      kube-system   coredns-5b6649768f-xnv7c                                        1/1     Running     0          61m
      kube-system   metrics-server-5d9d8b9889-4rbfr                                 1/1     Running     0          61m
      nginx         simplehome-deploy-74bbb54798-296gp                              1/1     Running     0          58m
      nginx         simplehome-deploy-74bbb54798-9h7lz                              1/1     Running     0          58m
      nginx         simplehome-deploy-74bbb54798-vcn2k                              1/1     Running     0          58m
      pks-system    cert-generator-1311f65a5dfa4bf6774ba070152672eacdb3e6b2-thlpq   0/1     Completed   0          61m
      pks-system    event-controller-6969f56f88-tqgzj                               2/2     Running     0          61m
      pks-system    fluent-bit-xb2sd                                                2/2     Running     0          61m
      pks-system    metric-controller-5dfd968d6f-px9vn                              1/1     Running     0          61m
      pks-system    node-exporter-rcsgs                                             1/1     Running     0          61m
      pks-system    observability-manager-6fd5d796fb-2knrd                          1/1     Running     0          61m
      pks-system    sink-controller-7799b4f4d7-wl9gm                                1/1     Running     0          61m
      pks-system    telegraf-s7q6t                                                  1/1     Running     0          61m
      pks-system    telemetry-agent-778fc8997d-w85f6                                2/2     Running     0          60m
      pks-system    validator-5787b98d57-c42nb                                      1/1     Running     0          61m
   