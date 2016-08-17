# Spark Streaming Write into MySQL
將即時分析的結果存入MySQL


##程式碼(JAVA)

* mysql : mysql資料庫名稱
* "root" : 帳號
* "mysql" : 密碼

```
mcConnect = DriverManager.getConnection( "jdbc:mysql://127.0.0.1/mysql", "root", "mysql");

```

* packetData :  資料表名稱
* (name , value ) : 資料表的欄位名稱

```
mStatement = mcConnect.prepareStatement("insert into packetData(name,value) values (?,?)");

```





* 將數值塞入資料表欄位
* setString ( 1 , value) : 第一個欄位
* setString ( 1 , value) :  塞入的數值

```
mStatement.setString(1, value);
mStatement.setString(2, "1");
mStatement.executeUpdate();


```




```
package com.imac;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function2;
import org.apache.spark.streaming.Durations;
import org.apache.spark.streaming.Time;
import org.apache.spark.streaming.api.java.JavaDStream;
import org.apache.spark.streaming.api.java.JavaReceiverInputDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;

import com.google.common.collect.Lists;

public final class JavaSqlNetworkWordCount {
        private static final Pattern SPACE = Pattern.compile(" ");

        public static void main(String[] args) {
                if (args.length < 2) {
                        System.err.println("Usage: JavaNetworkWordCount <hostname> <port>");
                        System.exit(1);
                }

                SparkConf sparkConf = new SparkConf().setMaster("local[2]").setAppName(
                                "JavaSqlNetworkWordCount");
                JavaStreamingContext ssc = new JavaStreamingContext(sparkConf,
                                Durations.seconds(1));

                JavaReceiverInputDStream<String> lines = ssc.socketTextStream(args[0],
                                Integer.parseInt(args[1]));
                JavaDStream<String> words = lines
                                .flatMap(new FlatMapFunction<String, String>() {
                                        @Override
                                        public Iterable<String> call(String x) {
                                                return Lists.newArrayList(SPACE.split(x));
                                        }
                                });
                // Convert RDDs of the words DStream to DataFrame and run SQL query
                words.foreachRDD(new Function2<JavaRDD<String>, Time, Void>() {
                        @Override
                        public Void call(JavaRDD<String> rdd, Time time)
                                        throws SQLException {

                                Connection mcConnect = null;
                                PreparedStatement mStatement = null;
                                try {
                                        mcConnect = DriverManager.getConnection(
                                                        "jdbc:mysql://127.0.0.1/mysql", "root", "mysql");
                                        mStatement = mcConnect.prepareStatement("insert into packetData(name,value) values (?,?)");
                                        List<String> list =rdd.collect();
                                        if (list.size()>0) {
                                                for(String value : list){
                                                        mStatement.setString(1, value);
                                                        mStatement.setString(2, "1");
                                                        mStatement.executeUpdate();
                                                }
                                        } 

                                } finally {
                                        if (mcConnect != null) {
                                                mcConnect.close();
                                        }
                                        if (mStatement != null) {
                                                mStatement.close();
                                        }
                                }

                                return null;
                        }
                });

                ssc.start();
                ssc.awaitTermination();
        }
}

```