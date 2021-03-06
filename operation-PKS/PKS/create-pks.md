
##### 1. om cli install   
##### https://github.com/pivotal-cf/om/releases   

    wget https://github.com/pivotal-cf/om/releases/download/5.0.0/om-linux-5.0.0.tar.gz
    tar xvf om-linux-5.0.0.tar.gz
    chmod +x om
    sudo cp om /usr/local/bin/

    ubuntu@opsmgr-02:~/bosh$ om
    om helps you interact with an Ops Manager
    
    Usage:
      om [options] <command> [<args>]
    
    Commands:
      activate-certificate-autho

##### 2. set bosh-env   

    ubuntu@opsmgr-02:~/bosh$ cat << EOF > ./env.yml
    > ---
    > target: xxxxx    #opsman URL
    > connect-timeout: 30
    > request-timeout: 3600
    > skip-ssl-validation: true
    > username: admin
    > password: 'xxxxxx'
    > decryption-passphrase: 'xxxxxx'
    > EOF

    ubuntu@opsmgr-02:~/bosh$ om --env ./env.yml bosh-env
    ubuntu@opsmgr-02:~/bosh$ om --env ./env.yml bosh-env > bosh-env.sh
    ubuntu@opsmgr-02:~/bosh$ source bosh-env.sh
    ubuntu@opsmgr-02:~/bosh$ bosh env
    Using environment 'xxx.xxx.xxx' as client 'ops_manager'
    Name               p-bosh
    UUID               e90942d7-e118-43ad-9b9f-deb4c101b21b
    Version            270.11.1 (00000000)
    Director Stemcell  ubuntu-xenial/621.71
    CPI                vsphere_cpi
    Features           compiled_package_cache: disabled
                       config_server: enabled
                       local_dns: enabled
                       power_dns: disabled
                       snapshots: disabled
    User               ops_manager
    Succeeded
    
    ubuntu@opsmgr-02:~/bosh$ bosh -d pivotal-container-service-200bf7e1e8023fb36671 instances
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Task 37. Done
    
    Deployment 'pivotal-container-service-200bf7e1e8023fb36671'
    
    Instance                                                        Process State  AZ       IPs          Deployment
    pivotal-container-service/1f3a8293-9c5e-476f-820f-1c331367755d  running        pks-az1  172.16.2.12  pivotal-container-service-200bf7e1e8023fb36671
    pks-db/c838f42a-d0ff-4b77-84c5-25dff0e31138                     running        pks-az1  172.16.2.11  pivotal-container-service-200bf7e1e8023fb36671
    
    2 instances
    
    Succeeded


##### 3. uaac access   

    cat /etc/hosts edit

    -> Access uaac in PKS
    ubuntu@opsmgr-02:~/pks$ uaac target https://$PKS_API:8443 --ca-cert api.crt --skip-ssl-validation
    Target: https://xxxx.xxxx.xx:8443

    -> Get Token
    ubuntu@opsmgr-02:~/pks$ uaac token client get admin -s xxxxxxx (Pks Uaa Management Admin Client)
    Unknown key: Max-Age = 86400
    Successfully fetched token via client credentials grant.
    Target: https://api.run.xxx.xxx.xxx.xxx:8443
    Context: admin, from client admin
    
    ubuntu@opsmgr-02:~/pks$

##### 4. Add uer in uaa    

    -> Add User
    ubuntu@opsmgr-02:~/pks$ uaac user add dbha  --emails xxxx@xxxxx.com -p 'xxxxxx'
    user account successfully added
    ubuntu@opsmgr-02:~/pks$
    
    ubuntu@opsmgr-02:~/pks$ uaac member add pks.clusters.admin dbha
    success

#### 5. PKS operation   

    -> download TKGI CLI
    https://network.pivotal.io/products/pivotal-container-service/#/releases/613165/file_groups/2492
    
    ubuntu@opsmgr-02:~$ sudo mv pks-linux-amd64-1.7.0-build.483 /usr/local/bin/pks
    ubuntu@opsmgr-02:~$ pks
    
    The Pivotal Container Service (PKS) CLI is used to create, manage, and delete Kubernetes clusters. To deploy workloads to a Kubernetes cluster created using the PKS CLI, use the Kubernetes CLI, kubectl.
    
    Version: 1.7.0-build.483

    -> pks login   
    ubuntu@opsmgr-02:~/pks$ pks login -a $PKS_API -u dbha -k
    
    Password: **********
    API Endpoint: xxxxxxx
    User: dbha
    Login successful.
    
    ubuntu@opsmgr-02:~/pks$

    -> create cluster
    ubuntu@opsmgr-02:~/pks$ cat << EOF > create_pks_cluster.sh
    > pks create-cluster my-205-01 \
    > --external-hostname my-205-01.pksdemo.net \
    > --plan small --num-nodes 3
    > EOF

    ubuntu@opsmgr-02:~/pks$ ./create_pks_cluster.sh
    PKS Version:              1.7.0-build.26
    Name:                     my-205-01
    K8s Version:              1.16.7
    Plan Name:                small
    UUID:                     70ce225a-a5fd-486c-a21a-67b3536da370
    Last Action:              CREATE
    Last Action State:        in progress
    Last Action Description:  Creating cluster
    Kubernetes Master Host:   my-205-01.pksdemo.net
    Kubernetes Master Port:   8443
    Worker Nodes:             3
    Kubernetes Master IP(s):  In Progress
    Network Profile Name:
    Kubernetes Profile Name:
    Tags:
    Use 'pks cluster my-205-01' to monitor the state of your cluster
    
    ubuntu@opsmgr-02:~/pks$ pks clusters
    
    PKS Version     Name       k8s Version  Plan Name  UUID                                  Status       Action
    1.7.0-build.26  my-205-01  1.16.7       small      70ce225a-a5fd-486c-a21a-67b3536da370  in progress  CREATE

    -> check cluster
    ubuntu@opsmgr-02:~$ pks clusters
    
    PKS Version     Name       k8s Version  Plan Name  UUID                                  Status     Action
    1.7.0-build.26  my-205-01  1.16.7       small      70ce225a-a5fd-486c-a21a-67b3536da370  succeeded  CREATE
    
    ubuntu@opsmgr-02:~$ pks cluster my-205-01
    
    PKS Version:              1.7.0-build.26
    Name:                     my-205-01
    K8s Version:              1.16.7
    Plan Name:                small
    UUID:                     70ce225a-a5fd-486c-a21a-67b3536da370
    Last Action:              CREATE
    Last Action State:        succeeded
    Last Action Description:  Instance provisioning completed
    Kubernetes Master Host:   my-205-01.pksdemo.net
    Kubernetes Master Port:   8443
    Worker Nodes:             3
    Kubernetes Master IP(s):  10.195.70.128
    Network Profile Name:
    Kubernetes Profile Name:
    Tags:

    -> bosh check
    ubuntu@opsmgr-02:~$ bosh -d service-instance_70ce225a-a5fd-486c-a21a-67b3536da370 instances
    Using environment '172.16.1.11' as client 'ops_manager'
    
    Task 72. Done
    
    Deployment 'service-instance_70ce225a-a5fd-486c-a21a-67b3536da370'
    
    Instance                                           Process State  AZ       IPs         Deployment
    apply-addons/9aafcb03-56fa-4785-843c-e52c50ce9730  -              pks-az1  -           service-instance_70ce225a-a5fd-486c-a21a-67b3536da370
    master/b1db98de-fcc4-4325-a954-9f3b1237a2d0        running        pks-az1  172.28.0.2  service-instance_70ce225a-a5fd-486c-a21a-67b3536da370
    worker/2a40890f-b4e8-48f4-a275-e41bbe72bf99        running        pks-az2  172.28.0.4  service-instance_70ce225a-a5fd-486c-a21a-67b3536da370
    worker/cbed53d1-86d3-466c-8cac-ec7ecf8cfd03        running        pks-az1  172.28.0.3  service-instance_70ce225a-a5fd-486c-a21a-67b3536da370
    worker/dabf4706-72c0-49be-a20d-07707ca75876        running        pks-az3  172.28.0.5  service-instance_70ce225a-a5fd-486c-a21a-67b3536da370
    
    5 instances
    
    Succeeded

##### 6. K8s Check using kubectl     
##### curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl

    ubuntu@opsmgr-02:~/pks$ sudo mv kubectl /usr/local/bin/
    ubuntu@opsmgr-02:~/pks$
    
    ubuntu@opsmgr-02:~/pks$ pks get-credentials my-205-01
    
    Fetching credentials for cluster my-205-01.
    Context set for cluster my-205-01.
    
    You can now switch between clusters by using:
    $kubectl config use-context <cluster-name>
    ubuntu@opsmgr-02:~/pks$ kubectl config get-contexts
    CURRENT   NAME        CLUSTER     AUTHINFO                               NAMESPACE
    *         my-205-01   my-205-01   224e303f-da2a-4c37-8e1a-e0d64fbf11ef
    ubuntu@opsmgr-02:~/pks$
    
    ubuntu@opsmgr-02:~$ pks cluster my-205-01
    
    PKS Version:              1.7.0-build.26
    Name:                     my-205-01
    K8s Version:              1.16.7
    Plan Name:                small
    UUID:                     70ce225a-a5fd-486c-a21a-67b3536da370
    Last Action:              CREATE
    Last Action State:        succeeded
    Last Action Description:  Instance provisioning completed
    Kubernetes Master Host:   my-205-01.pksdemo.net
    Kubernetes Master Port:   8443
    Worker Nodes:             3
    Kubernetes Master IP(s):  10.195.70.128
    Network Profile Name:
    Kubernetes Profile Name:
    Tags:
    
    ubuntu@opsmgr-02:~$ cat /etc/hosts | grep 10.195.70.128
    10.195.70.128 my-205-01.pksdemo.net
    ubuntu@opsmgr-02:~$
    
    ubuntu@opsmgr-02:~$ kubectl get nodes
    NAME                                   STATUS   ROLES    AGE   VERSION
    15f68f12-9fcb-4364-bd9c-de0548cc27b6   Ready    <none>   50m   v1.16.7+vmware.1
    69df2019-a2ec-4519-a3ae-4d2933ff0d6b   Ready    <none>   53m   v1.16.7+vmware.1
    f6d69484-3818-4189-b8ac-8bc0ec8c0f79   Ready    <none>   46m   v1.16.7+vmware.1
    ubuntu@opsmgr-02:~$





