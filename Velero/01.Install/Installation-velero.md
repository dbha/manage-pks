##### 01. Download Velero   
    ubuntu@opsmgr-02:~/velero$ wget https://github.com/vmware-tanzu/velero/releases/download/v1.4.0/velero-v1.4.0-linux-amd64.tar.gz
    ubuntu@opsmgr-02:~/velero$ tar xvf velero-v1.4.0-linux-amd64.tar.gz
    
    ubuntu@opsmgr-02:~/velero$ ls -lrt
    total 49388
    -rw-rw-r-- 1 ubuntu ubuntu 23832176 May 26 20:36 velero-v1.4.0-linux-amd64.tar.gz
    drwxrwxr-x 3 ubuntu ubuntu     4096 Aug 23 08:02 velero-v1.4.0-linux-amd64

    ubuntu@opsmgr-02:~/velero$ cd velero-v1.4.0-linux-amd64
    ubuntu@opsmgr-02:~/velero/velero-v1.4.0-linux-amd64$ ls -lrt
    total 56484
    -rw-r--r-- 1 ubuntu ubuntu    10255 Dec  9  2019 LICENSE
    -rwxr-xr-x 1 ubuntu ubuntu 57810814 May 26 20:33 velero
    drwxrwxr-x 4 ubuntu ubuntu     4096 Aug 23 01:30 examples
    -rw-rw-r-- 1 ubuntu ubuntu       70 Aug 23 01:35 credentials-velero
    -rwxrwxr-x 1 ubuntu ubuntu      923 Aug 23 02:25 velero-install.sh
    -rw-rw-r-- 1 ubuntu ubuntu      284 Aug 23 02:56 po-annotate.sh
    ubuntu@opsmgr-02:~/velero/velero-v1.4.0-linux-amd64$
    ubuntu@opsmgr-02:~/velero/velero-v1.4.0-linux-amd64$ cp velero /usr/local/bin/    

    ubuntu@opsmgr-02:~/velero/velero-v1.4.0-linux-amd64$ velero
    Velero is a tool for managing disaster recovery, specifically for Kubernetes
    cluster resources. It provides a simple, configurable, and operationally robust
    way to back up your application state and associated data.
    
    If you're familiar with kubectl, Velero supports a similar model, allowing you to
    execute commands such as 'velero get backup' and 'velero create schedule'. The same
    operations can also be performed as 'velero backup get' and 'velero schedule create'.
    
    Usage:
      velero [command]
    
    Available Commands:
      backup            Work with backups
      backup-location   Work with backup storage locations
      bug               Report a Velero bug
      client            Velero client related commands
      completion        Output shell completion code for the specified shell (bash or zsh)
      create            Create velero resources
      delete            Delete velero resources
      describe          Describe velero resources
      get               Get velero resources
      help              Help about any command
      install           Install Velero
      plugin            Work with plugins
      restic            Work with restic
      restore           Work with restores
      schedule          Work with schedules
      snapshot-location Work with snapshot locations
      version           Print the velero version and associated image
  
##### 02. Install Minio   
    -> minio 가 기본적으로 설치되어 있다고 가정, mc install
    wget https://dl.min.io/client/mc/release/linux-amd64/mc
    chmod +x mc
    ./mc --help
    
    -> mc config
    mc config host add minio http://172.16.1.12:9000 admin xxxxxx
    ubuntu@opsmgr-02:~/minio$ mc alias ls
    gcs
      URL       : https://storage.googleapis.com
      AccessKey : YOUR-ACCESS-KEY-HERE
      SecretKey : YOUR-SECRET-KEY-HERE
      API       : S3v2
      Path      : dns
    
    local
      URL       : http://localhost:9000
      AccessKey :
      SecretKey :
      API       :
      Path      : auto
    
    minio
      URL       : http://172.16.1.12:9000
      AccessKey : admin
      SecretKey : changeme!
      API       : s3v4
      Path      : auto
    
    
    ubuntu@opsmgr-02:~/minio$ mc mb minio/velero
    Bucket created successfully `minio/velero`.
    ubuntu@opsmgr-02:~/minio$
    ubuntu@opsmgr-02:~/minio$ mc ls minio
    [2020-08-23 02:35:43 UTC]      0B velero/
    
##### 03. Install Velero(1.4.0) for PKS

    -> Command to install Velero on the K8s cluster:
    
    ubuntu@opsmgr-02:~/velero/velero-v1.4.0-linux-amd64$ cat velero-install.sh
    velero install  --provider aws --bucket velero \
      --secret-file ./credentials-velero --use-volume-snapshots=false \
      --plugins velero/velero-plugin-for-aws:v1.0.1 --use-restic \
      --backup-location-config region=minio,s3ForcePathStyle="true",s3Url=http://172.16.1.12:9000,publicUrl=http://172.16.1.12:9000
      
    ubuntu@opsmgr-02:~/velero/velero-v1.4.0-linux-amd64$ ./velero-install.sh
    CustomResourceDefinition/backups.velero.io: attempting to create resource
    CustomResourceDefinition/backups.velero.io: already exists, proceeding
    CustomResourceDefinition/backups.velero.io: created
    CustomResourceDefinition/backupstoragelocations.velero.io: attempting to create resource
    CustomResourceDefinition/backupstoragelocations.velero.io: already exists, proceeding
    CustomResourceDefinition/backupstoragelocations.velero.io: created
    CustomResourceDefinition/deletebackuprequests.velero.io: attempting to create resource
    CustomResourceDefinition/deletebackuprequests.velero.io: already exists, proceeding
    CustomResourceDefinition/deletebackuprequests.velero.io: created
    CustomResourceDefinition/downloadrequests.velero.io: attempting to create resource
    
##### 04. Change hostPath in PKS po   

    -> Change hostPath
    hostPath:
      path: /var/vcap/data/kubelet/pods
      
    ubuntu@opsmgr-02-haas-252-pez-pivotal-i:~/velero/velero-v1.4.0-linux-amd64$ kubectl edit ds restic -n velero
    daemonset.apps/restic edited
    