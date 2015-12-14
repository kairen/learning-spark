package com.imac.example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;

import java.util.Arrays;

/**
 * Created by kairenbai on 2015/3/19.
 */

public class Example {

    public static void main(String[] argv) {

//        if (argv.length != 3) {
//            System.err.printf("Usage: %s [generic options] <input> <search input> <output>\n",
//                    Example.class.getSimpleName());
//            return ;
//        }
//
//        String inputpath = argv[0];
//        String searchPath = argv[1];
//        String outputPath = argv[2];
//
//        SparkConf conf = new SparkConf().setAppName("TF").setMaster("yarn-cluster");
//        JavaSparkContext sparkContext = new JavaSparkContext(conf);
//
//        JavaRDD<String> searchRDD = sparkContext.textFile(searchPath);
//        JavaRDD<String> sourceRDD = sparkContext.textFile(inputpath);
//
//
//        final JavaRDD<String> keyWords = searchRDD.flatMap(new FlatMapFunction<String, String>() {
//            @Override
//            public Iterable<String> call(String line) throws Exception {
//                return Arrays.asList(line.split(","));
//            }
//        });
//
//        keyWords.filter(new Function<String, Boolean>() {
//            public Boolean call(String line) throws Exception {
//                System.out.println("Inside filter words ->" + line);
//                if(line.trim().length() == 0)
//                    return false;
//                return true;
//            }
//        });
//
//        JavaPairRDD words = sourceRDD.mapToPair(new CompareWordFunction(keyWords)).flatMapValues(
//                new Function<String, Iterable>() {
//                    @Override
//                    public Iterable call(String s) throws Exception {
//                        return Arrays.asList("Key");
//                    }
//                }
//        );
//
//
////        JavaPairRDD<String, Integer> wordToCountMap = words.mapToPair(new PairFunction<String, String, Integer>() {
////            public Tuple2<String, Integer> call(String s) throws Exception {
////
////                return new Tuple2<String, Integer>(s, 1);
////            }
////        });
////
////        JavaPairRDD<String, Integer> wordCounts = wordToCountMap.reduceByKey(new Function2<Integer, Integer, Integer>() {
////            public Integer call(Integer first, Integer second) throws Exception {
////                return first + second;
////            }
////        });
//
//        words.saveAsTextFile(outputPath);
//        keyWords.saveAsTextFile(outputPath+"/search");
    }


}
