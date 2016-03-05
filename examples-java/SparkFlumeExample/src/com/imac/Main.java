package com.imac;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.examples.streaming.StreamingExamples;
import org.apache.spark.streaming.Duration;
import org.apache.spark.streaming.api.java.JavaDStream;
import org.apache.spark.streaming.api.java.JavaReceiverInputDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;
import org.apache.spark.streaming.flume.FlumeUtils;
import org.apache.spark.streaming.flume.SparkFlumeEvent;

public class Main{	

	public static void main(String[] args) {
		if (args.length != 2) {
			System.err.println("Usage: FlumeTest <host> <port>");
			System.exit(1);
		}
		
		StreamingExamples.setStreamingLogLevels();
		
		String host = args[0];
		int port = Integer.parseInt(args[1]);
		
		Duration batchInterval = new Duration(2000);
		SparkConf conf = new SparkConf().setAppName("JavaFlumeStreaming");
//		conf.setMaster("yarn-cluster");
		JavaStreamingContext sc = new JavaStreamingContext(conf, batchInterval);
		JavaReceiverInputDStream<SparkFlumeEvent> dStream = FlumeUtils.createStream(sc, host, port);
		dStream.cache();
		dStream.map(new Function<SparkFlumeEvent, String>() {

			@Override
			public String call(SparkFlumeEvent arg0) throws Exception {
				// TODO Auto-generated method stub
				return arg0.event().getBody().array().toString();
			}
		}).print();
		
//		dStream.count();
//		dStream.count().map(new Function<Long, String>() {
//
//			@Override
//			public String call(Long arg0) throws Exception {
//				return "Received " + arg0 + " flume events.";
////				return arg0.\;
//			}
//		}).print();

//		JavaReceiverInputDStream<String> lines = sc.socketTextStream(host, port);
//		
//		JavaDStream<String> words = lines.map(new Function<String, String>() {
//
//			@Override
//			public String call(String arg0) throws Exception {
//				// TODO Auto-generated method stub
//				return arg0.split(" ").toString();
//			}
//		});
//		
//		words.print();
		
		sc.start();
		sc.awaitTermination();
	}

}
