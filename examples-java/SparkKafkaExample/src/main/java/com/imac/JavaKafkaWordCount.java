package com.imac;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Arrays;

import kafka.serializer.StringDecoder;

import org.apache.spark.SparkConf;
import org.apache.spark.examples.streaming.StreamingExamples;
import org.apache.spark.streaming.api.java.*;
import org.apache.spark.streaming.kafka.KafkaUtils;
import org.apache.spark.streaming.Durations;

public final class JavaKafkaWordCount {
	  public static void main(String[] args) {
	    if (args.length < 2) {
	      System.err.println("Usage: JavaDirectKafkaWordCount <brokers> <topics>");
	      System.exit(1);
	    }

	    StreamingExamples.setStreamingLogLevels();

	    String brokers = args[0];
	    String topics = args[1];

	    SparkConf sparkConf = new SparkConf().setAppName("JavaDirectKafkaWordCount");
	    JavaStreamingContext jssc = new JavaStreamingContext(sparkConf, Durations.seconds(2)); //2 seconds batch interval

	    HashSet<String> topicsSet = new HashSet<String>(Arrays.asList(topics.split(",")));
	    HashMap<String, String> kafkaParams = new HashMap<String, String>();
	    kafkaParams.put("metadata.broker.list", brokers);

	    // Create direct kafka stream with brokers and topics
	    JavaPairInputDStream<String, String> messages = KafkaUtils.createDirectStream(
	        jssc,
	        String.class,
	        String.class,
	        StringDecoder.class,
	        StringDecoder.class,
	        kafkaParams,
	        topicsSet
	    );

	    messages.print();

	    // Start the computation
	    jssc.start();
	    jssc.awaitTermination();
	  }
	}