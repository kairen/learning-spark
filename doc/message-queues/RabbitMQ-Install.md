# Rabbit MQ
Rabbit Message Queue 是實作了```AMQP（Advanced Message Queuing Protocol ）```的軟體套件，是導向訊息的中介軟體，RabbitMQ Server 是透過```Erlang```語言撰寫而成，它所能做就是處理數位化資料的訊息接收，再把訊息發送出去。而在叢集與故障轉移是建構於開發電信平台框架上，所以支援了多程式語言的代理介面通訊的客戶端 Library。

## 安裝 Rabbit MQ
一個簡單的節點配置如下：

| IP Address  |   Role   |
|-------------|----------|
|172.17.0.2   | server-1 |
|172.17.0.3   | server-2 |
|172.17.0.4   | server-3 |

首先加入 Repos 取得最新版本套件來源：
```sh
$ echo "deb http://www.rabbitmq.com/debian/ testing main" | sudo tee /etc/apt/sources.list.d/rabbitmq.list
$ wget http://www.rabbitmq.com/rabbitmq-signing-key-public.asc
$ sudo apt-key add rabbitmq-signing-key-public.asc && rm rabbitmq-signing-key-public.asc
$ sudo apt-get update
$ sudo apt-get install rabbitmq-server
```

新增一個使用者，並設定權限：
```sh
$ sudo rabbitmqctl add_user spark spark
$ sudo rabbitmqctl set_permissions spark ".*" ".*" ".*"
```

### Spark Library
* https://github.com/Stratio/Spark-RabbitMQ

(待更新...)
