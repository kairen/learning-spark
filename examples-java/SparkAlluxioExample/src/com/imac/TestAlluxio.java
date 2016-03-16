package com.imac.alluxio;

import org.apache.hadoop.conf.Configuration;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

public class TestAlluxio {
	public static void main(String[] args) {
		JavaSparkContext sc = new JavaSparkContext();
		Configuration conf = sc.hadoopConfiguration();
		conf.set("fs.alluxio.impl", "alluxio.hadoop.FileSystem");
		JavaRDD<String> rawRDD = sc.textFile(args[0]);
		//alluxio://localhost:19998/imac
		rawRDD.saveAsTextFile(args[1]);
	}

}
