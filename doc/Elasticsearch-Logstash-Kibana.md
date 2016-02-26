# ELK 安裝與設定
ELK 是由三個套件的開頭英文組成的縮寫，其 E 表示```Elasticsearch```，L 表示```Logstash```，K 表示```Kibana```，作為收集資料、資料索引以及資料視覺化的工具集合，以下分別簡單介紹三個套件。

### Logstash
Logstash 可以簡單、有效、快速的處理Log資料，不過Logstash的主要功能是處理時間類型的Log，也就是在Log檔中有時間戳記（TimeStamp）的資料，而分析Log資料主要就是分析事件發生的時間和內容

#### Logstash Forwarder
可傳送所收集到的 Log 訊息到 Logstash。

### Elasticsearch
Elasticsearch 是一個開源的資料搜尋分析系統，它可以解決現在 Web 去做資料庫的搜尋的種種問題，嚴格來說也不只是 web，(有可能是為了撈資料的效能，或是 schema free,  real-time 等等)。

### Kibana
Kibana 是一個開源和免費的工具，他可以幫助您匯總、分析和搜索重要數據日志並提供友好的web界面

### 系統
* OS: Ubuntu 14.04
* Elasticsearch 1.4.4
* Logstash 1.5.0
* Kibana 4


## 安裝

### 首先安裝 Java Oracle
```
sudo apt-get purge openjdk*
sudo apt-get -y autoremove
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get update
echo debconf shared/accepted-oracle-license-v1-1 select true | sudo debconf-set-selections
echo debconf shared/accepted-oracle-license-v1-1 seen true | sudo debconf-set-selections
sudo apt-get -y install oracle-java7-installer 

```

### 安裝 Elasticsearch

匯入 Elasticsearch public GPG key 到 apt
```
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
```

建立 Elasticsearch source list：
```
echo 'deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main' | sudo tee /etc/apt/sources.list.d/elasticsearch.list
```

更新套件：
```
sudo apt-get update
```

安裝 elasticsearch 1.4.4：
```
sudo apt-get -y install elasticsearch=1.4.4
```

安裝完成，開啟配置檔：
```
sudo vi /etc/elasticsearch/elasticsearch.yml
```

如果想限制給外界存取 Elasticsearch，可找到  ```network.host``` ，將內容取代成"localhost"，如下：
```
network.host: localhost
```

開啟 Elasticsearch：
```
sudo service elasticsearch restart
```

重開機立即啟動 Elasticsearch ：
```
sudo update-rc.d elasticsearch defaults 95 10
```

### 安裝 Kibana
下載 Kibana 4 到 opt 資料夾
```
cd /opt
```
使用```wget```下載 Kibana 套件壓縮檔：
```
wget https://download.elasticsearch.org/kibana/kibana/kibana-4.0.1-linux-x64.tar.gz
```

解壓縮檔案：
```
tar xvf kibana-*.tar.gz
```

開啟 Kibana 配置檔：
```
vi ~/kibana-4*/config/kibana.yml
```

配置檔中找到 ```host``` 將 IP address "0.0.0.0" 取代成 "localhost"，此設定讓 Kibana 只能被 localhost 存取，如下：
```
host: "localhost"
```

將下載完的 kibana 資料夾名稱改成 kibana：
```
sudo mv kibana-4.0.1-linux-x64 kibana
```

Kibana 執行 ```/opt/kibana/bin/kibana``` 來開啟，但我們想用 service 的方式開啟。

Download a Kibana init script with this command :
```
cd /etc/init.d && sudo wget https://gist.githubusercontent.com/thisismitch/8b15ac909aed214ad04a/raw/bce61d85643c2dcdfbc2728c55a41dab444dca20/kibana4
```

開啟 Kibana service：
```
sudo chmod +x /etc/init.d/kibana4
sudo update-rc.d kibana4 defaults 96 9
sudo service kibana4 start
```

### 安裝 Logstash
建立 Logstash source list：
```
echo 'deb http://packages.elasticsearch.org/logstash/1.5/debian stable main' | sudo tee /etc/apt/sources.list.d/logstash.list
```

更新套件：
```
sudo apt-get update
```

安裝 Logstash： 
```
sudo apt-get install logstash
```

### 產生 SSL 認證
因為我們將使用 Logstash Forwarder 收集 logs並傳送到 Logstash Server ，所以我們必須建立一對SSL 認證的 key：
```
sudo mkdir -p /etc/pki/tls/certs
sudo mkdir /etc/pki/tls/private
```

設定 openssl 配置：
```
sudo vi /etc/ssl/openssl.cnf
```

配置檔中找到 ``` [ v3_ca ]``` ，並新增以下內容：
```
subjectAltName = IP:logstash_server_private_ip
```

產生 SSL 認證和 private key 到 ```/etc/pki/tls/``` ，如下：
```
cd /etc/pki/tls
```

設定 SSL 驗證：
```
sudo openssl req -config /etc/ssl/openssl.cnf -x509 -days 3650 -batch -nodes -newkey rsa:2048 -keyout private/logstash-forwarder.key -out certs/logstash-forwarder.crt
```

### 配置 Logstash
新增配置檔 ```01-lumberjack-input.conf```：
```
sudo vi /etc/logstash/conf.d/01-lumberjack-input.conf
```

新增以下配置內容：
```
input {
  lumberjack {
    port => 5000
    type => "logs"
    ssl_certificate => "/etc/pki/tls/certs/logstash-forwarder.crt"
    ssl_key => "/etc/pki/tls/private/logstash-forwarder.key"
  }
}
```

新增配置檔 ```10-syslog.conf```：
```
sudo vi /etc/logstash/conf.d/10-syslog.conf
```

新增以下配置內容：
```
filter {
  if [type] == "syslog" {
    grok {
      match => { "message" => "%{SYSLOGTIMESTAMP:syslog_timestamp} %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?: %{GREEDYDATA:syslog_message}" }
      add_field => [ "received_at", "%{@timestamp}" ]
      add_field => [ "received_from", "%{host}" ]
    }
    syslog_pri { }
    date {
      match => [ "syslog_timestamp", "MMM  d HH:mm:ss", "MMM dd HH:mm:ss" ]
    }
  }
}
```

新增配置檔 ```30-lumberjack-output.conf```：
```
sudo vi /etc/logstash/conf.d/30-lumberjack-output.conf
```

新增以下配置內容：
```
output {
  elasticsearch { host => localhost }
  stdout { codec => rubydebug }
}
```

重啟 Logstash：
```
sudo service logstash restart
```

完成後就可以設置```Logstash Forwarder```（簡單說就是加入 Client）。

#### 複製 SSL Certificate 與 Logstash Forwarder 套件 (```On Logstash Server```)
```
scp /etc/pki/tls/certs/logstash-forwarder.crt user@client_server_private_address:/tmp
```

#### 安裝 Logstash Forwarder 套件 (```On Client```)
Logstash Forwarder source list：
```
echo 'deb http://packages.elasticsearch.org/logstashforwarder/debian stable main' | sudo tee /etc/apt/sources.list.d/logstashforwarder.list
```

一樣可使用Elasticsearch的 GPG key 來安裝：
```
wget -O - http://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -
```

安裝 Logstash Forwarder package：
```
sudo apt-get update
sudo apt-get install logstash-forwarder
```

複製 Logstash server's SSL認證到 ```/etc/pki/tls/certs```：
```
sudo mkdir -p /etc/pki/tls/certs
sudo cp /tmp/logstash-forwarder.crt /etc/pki/tls/certs/
```

#### 配置 Logstash Forwarder
設定Logstash Forwarder 配置檔(```On Client Server```)：
```
sudo vi /etc/logstash-forwarder.conf
```

配置檔中找到 ```network``` ，底下加入以下內容：
```
"servers": [ "logstash_server_private_address:5000" ],
    "timeout": 15,
    ssl ca": "/etc/pki/tls/certs/logstash-forwarder.crt"
```

配置檔中找到 ```files ``` ，底下加入以下內容：
```
   {
      "paths": [
        "/var/log/syslog",
        "/var/log/auth.log"
       ],
      "fields": { "type": "syslog" }
    }
```

重啟 Logstash Forwarder：
```
sudo service logstash-forwarder restart
```

完成後，即可開啟瀏覽器，網址列輸入[locahost:5601](locahost:5601)。