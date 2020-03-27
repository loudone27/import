# KENOBEE MIGRATION STUDY 

1°) Elasticsearch  
1.1°) Preparation  
  1.1.1°) Download the targz package 6.8.7  
    - elasticsearch-6.8.7.tar.gz  

  1.1.2°) Node Elasticsearch Home test information  
    Node1 => 192.168.1.51  
    Node2 => 192.168.1.52  
    Node3 => 192.168.1.53  

  1.1.3°) Stop Logstash  
    In order to limit the indexing instructions, it is preferable to stop logstash, which will limit a maximum of indexing request.  
    for stopping it please go here: 
  
  1.1.4°) Disable Shard allocation  
    When you shut down a node, the allocation process waits for **index.unassigned.node_left.delayed_timeout** (by default, one minute) 
    before starting to replicate the shards on that node to other nodes in the cluster, which can involve a lot of I/O. 
    Since the node is shortly going to be restarted, this I/O is unnecessary. 
    You can avoid racing the clock by disabling allocation of replicas before shutting down the node:  

```bash
    curl -X PUT "Kenobee_node:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
    {
        "persistent": {
        "cluster.routing.allocation.enable": "primaries"
        }
    }'
```

&#x1F538; **Please note:** You need to replace **Kenobee_node** by the correct IP address elasticsearch master node

1.2°) Migration Steps  
  For this step you can to do it one by one for to maintain cluster activity, but in degraded mode but keep in mind after migration it's possible to have some indice in yellow or red state if they are not replicate properly
  or you can stop all the cluster (all nodes, master and Data node), so you will stop definitively indexing possibility but you will prevent every indice state.

In order to stop node go here:  

  1.2.1°) Save actual node  
  In order to be able to rollback it is important to save the current binary directory of the node  
  For That, please follow the following step below:  

  ```bash
    With the user elasticsearch
    sudo -u elasticsearch -i
    cd /SERVICE/run/
    tar -zcvf kenobee_node.tar.gz kenobee_folder
  ```

&#x1F538; **Please note:** You need to replace **kenobee_node.tar.gz** & **kenobee_folder** by the correct elasticsearch folder node like below:  

  - Master Node:  **elasticsearh-6.5.4**  / **elasticsearh-6.5.4.tar.gz**
  - Data Node:    **elasticsearh-6.5.4_2**  /  **elasticsearh-6.5.4_2.tar.gz**

  1.2.2°) Save actual configuration files
  In order to be able to keep actual configuration it is important to save the current configurations file of the different nodes
  For That, please follow the following step below:

  ```bash
    With the user elasticsearch  
    sudo -u elasticsearch -i  
    
    cd /SERVICE/run/  
    mkdir -m 755 SAVE_CONF  
    cd SAVE_CONF  
    mkdir -m 755 master_node  
    mkdir -m 755 data_node  
    
    cd /SERVICE/run/kenobee_folder/config  
    cp elasticsearch.yml /SERVICE/run/SAVE_CONF/kenobee_node  
    cp jvm.options /SERVICE/run/SAVE_CONF/kenobee_node  
    mv kenobee_node.tar.gz /SERVICE/run/SAVE_CONF/kenobee_node  
    
  ```

&#x1F538; **Please note:** You need to replace **kenobee_node.tar.gz** & **kenobee_node** by the correct elasticsearch folder node like below:  

  - Master Node:  **Folder: master_node**  / **targz: elasticsearh-6.5.4.tar.gz**
  - Data Node:    **data_node**  /  **elasticsearh-6.5.4_2.tar.gz**


  1.2.3°) Add the new version package  
  For this we need to paste on the kenobee server the elactisearch tar.gz package for the migration node  
  Please following steps:

  ```bash
  With the user elasticsearch  
  sudo -u elasticsearch -i  
  
  cd /SERVICE/run/  
  mkdir -m 755 PACKAGES  
  ```
  Then use sftp tool (ex winscp) for copy package in the folder **/SERVICE/run/PACKAGES**  

  1.2.4°) Untar Package  
  For this step, you will create the new binary folder for the new elasticsearch node  
  Please follow these steps:  
  
  ```bash
  With the user elasticsearch  
  sudo -u elasticsearch -i  
  
  cd /SERVICE/run/PACKAGES  
  tar xvzf elasticsearch-6.8.7.tar.gz -C /SERVICE/run/
  
  ```

  1.2.5°) Add elasticsearch Data node to the new node  
  This step, you will paste all index data from the previous node to the new one  
  
  ```bash
  With the user elasticsearch  
  sudo -u elasticsearch -i  
  cd /SERVICE/run/kenobee_folder
  cp -r data /SERVICE/run/kenobee_folder_new
  ```
&#x1F538; **Please note:** You need to replace **kenobee_folder** & **kenobee_folder_new** by the correct elasticsearch folder node like below:  

  - kenobee_folder_master_node:  **Folder: elasticsearch-6.5.4**  
  - kenobee_folder_new_node_master:    **Folder: elasticsearch-6.8.7**  
  - kenobee_folder_data_node:  **Folder: elasticsearch-6.5.4_2**  
  - kenobee_folder_new_data_node:    **Folder: elasticsearch-6.8.7_2**  

  1.2.6°) Add elasticsearch configuration node to the new node  
  This Step, you will paste configuration files from the previous node to the new one  

  ```bash
  With the user elasticsearch  
  sudo -u elasticsearch -i  
  
  mv /SERVICE/run/kenobee_folder_new/config/elasticsearch.yml /SERVICE/run/kenobee_folder_new/config/elasticsearch.old
  mv /SERVICE/run/kenobee_folder_new/config/jvm.options /SERVICE/run/kenobee_folder_new/config/jvm.options.old
  
  cd /SERVICE/run/SAVE_CONF/kenobee_node  
  cp elasticsearch.yml /SERVICE/run/kenobee_folder_new/config  
  cp jvm.options /SERVICE/run/kenobee_folder_new/config  
  
  ```

&#x1F538; **Please note:** You need to replace **kenobee_node** & **kenobee_folder_new** by the correct elasticsearch folder node like below:  

  - kenobee_node_master:  **Folder: master_node**  
  - kenobee_data_master:  **Folder: data_node**  
  - kenobee_folder_new_master:    **Folder: elasticsearch-6.8.7**  
  - kenobee_folder_new_data_node:    **Folder: elasticsearch-6.8.7_2**  

  1.2.7°) Modify the Symbolic Links Destination  
  This step consist of changing the Symbolic Links and point it to the new elasticsearch's binary folder  
  
  ```bash
  With the user elasticsearch  
  sudo -u elasticsearch -i  
  
  rm -f node_link
  ln -s /SERVICE/run/kenobee_folder_new node_link
  ```
&#x1F538; **Please note:** You need to replace **node_link** & **kenobee_folder_new** by the correct elasticsearch folder node like below:  

  - node_link_master:  **Symbolic_link: elasticsearch**  
  - node_link_data_node:  **Symbolic_link: elasticsearch_2**  
  - kenobee_folder_new_master:    **Folder: elasticsearch-6.8.7**  
  - kenobee_folder_new_data_node:    **Folder: elasticsearch-6.8.7_2**  

  1.2.8°) Cleaning previous Binary folders  
  At this step the migration is done, so we can clean the older elasticsearch's binary folder  

  ```bash
  With the user elasticsearch  
  sudo -u elasticsearch -i  
  cd /SERVICE/run/  
  rm -rf kenobee_folder
  ```

&#x1F538; **Please note:** You need to replace **kenobee_folder** by the correct elasticsearch folder node like below:  

  - kenobee_folder_master_node:  **Folder: elasticsearch-6.5.4**  
  - kenobee_folder_data_node:  **Folder: elasticsearch-6.5.4_2**  
  
1.3°) POST Migration Steps  
  1.3.1°) Verify all node are join to the cluster

```bash
  curl -X GET "Kenobee_node:9200/_cat/nodes?pretty"
```

&#x1F538; **Please note:** You need to replace **Kenobee_node** by the correct IP address elasticsearch master node

  1.3.2°) Reenable shard allocation

  ```bash
curl -X PUT "Kenobee_node:9200/_cluster/settings?pretty" -H 'Content-Type: application/json' -d'
{
  "persistent": {
    "cluster.routing.allocation.enable": null
  }
}
'
```

&#x1F538; **Please note:** You need to replace **Kenobee_node** by the correct IP address elasticsearch master node


  1.3.3°) Verify actual state of indice

```bash
  curl -X GET "Kenobee_node:9200/_cat/indices?pretty"
```
&#x1F538; **Please note:** You need to replace **Kenobee_node** by the correct IP address elasticsearch master node

**Example result:**  

```bash
health status index                             uuid                   pri rep docs.count docs.deleted store.size pri.store.size
green  open   .monitoring-es-6-2020.03.24       FiYukW-eRYyXWJ6OcGVtAg   1   1     292452         1386    302.7mb        154.4mb
green  open   .monitoring-es-6-2020.03.27       E87meAQ5T9m5da6OjyToSQ   1   1     101902         1792    168.3mb         67.7mb
green  open   .monitoring-logstash-6-2020.03.26 wptp3RpXTc2F_BXqqb4XyQ   1   1      33384            0      4.3mb          2.1mb
green  open   .monitoring-kibana-6-2020.03.26   qQ1skxUBTEGesk6pPQBRWA   3   1       2588            0      1.8mb        966.1kb
green  open   access_log-2019.03.25             NdJWpfa6Tj2WxCpms3jAyg   3   1          1            0     20.5kb         10.2kb
green  open   .kibana                           aRPy685NRZWFYTOMx8Y63g   1   1          7            0     83.5kb         41.7kb
green  open   .monitoring-es-6-2020.03.25       9dq-N4R8SNCu2ZRv27Yfqg   1   1     155090          264    186.6mb           93mb
green  open   .monitoring-kibana-6-2020.03.25   Fn5up9UQSkWl5Z5LLiNhSA   3   1       5606            0      3.7mb          1.8mb
green  open   metricbeat-6.3.0-2019.05.22       vyHlezuwT5CKRGX27SI8ew   1   1      64278            0     16.1mb            8mb
green  open   .monitoring-es-6-2020.03.26       RkkkrKARSmqfqbkh4FWuLA   1   1     186732          378    222.2mb        111.9mb
green  open   parsing_test_log-2020.03.25       DwCCzRD8SLO_Usa-DfedWg   3   1       3097            0      2.1mb            1mb
green  open   solrbddf-2018.11.05               SLk9CvIWRauOXPTGIUZcaw   5   1         78            0    185.1kb         92.5kb
green  open   .monitoring-logstash-6-2020.03.25 B45T1hflQXyCyLyNdIT7aQ   1   1      68544            0      9.1mb          4.5mb
green  open   bailin_log-2019.09.05             YegoKt7RQZ2np1bSuSdI-Q   3   1          2            0     23.9kb         11.9kb
```

You need to verify that every indices have an green health state

