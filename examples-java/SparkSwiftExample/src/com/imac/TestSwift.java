package com.imac.swift;

import org.apache.hadoop.conf.Configuration;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;

public class TestSwift {
	
	
	public static void main(String[] args) {
		
		JavaSparkContext sc =new JavaSparkContext();
		Configuration conf = sc.hadoopConfiguration();
		conf.set("fs.swift.impl", "org.apache.hadoop.fs.swift.snative.SwiftNativeFileSystem");
		conf.set("fs.swift.service.test.auth.url", "http://163.17.136.246:5000/v2.0/tokens");
		conf.set("fs.swift.service.test.auth.endpoint.prefix", "endpoints");
		conf.set("fs.swift.service.test.http.port", "8080");
		conf.set("fs.swift.service.test.region", "RegionOne");
		conf.set("fs.swift.service.test.public", "true");
		conf.set("fs.swift.service.test.tenant", "big-data");
		conf.set("fs.swift.service.test.username", "k753357");
		conf.set("fs.swift.service.test.password", "k753357");
		JavaRDD<String> rawRDD = sc.textFile(args[0]);
		rawRDD.saveAsTextFile("swift://testfile.test/file/");
	}

}
