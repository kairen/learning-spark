package com.imac.example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.PairFunction;
import scala.Tuple2;

import java.util.Arrays;

/**
 * Created by kairenbai on 2015/12/11.
 */
public class SparkExample {

    public static void main(String []argv) {

        if (argv.length != 2) {
            System.err.printf("Usage: %s [generic options] <input> <output>\n",
                    SparkExample.class.getSimpleName());
            return ;
        }

        String inputPath = argv[0];
        String outputPath = argv[1];

        SparkConf conf = new SparkConf().setAppName("SparkExample").setMaster("yarn-cluster");

        JavaSparkContext sparkContext = new JavaSparkContext(conf);
        JavaRDD<String> fileRDD = sparkContext.textFile(inputPath, 1);

        JavaRDD<String> mapRDD = fileRDD.map(new Function<String, String>() {
            public String call(String arg0) throws Exception {
                return arg0.split(",")[0];
            }
        });

        JavaRDD<String> flatMapRDD = fileRDD.flatMap(new FlatMapFunction<String, String>() {
            public Iterable<String> call(String arg0)
                    throws Exception {
                return Arrays.asList(arg0.split(","));
            }
        });

        JavaRDD<String> filterRDD = flatMapRDD.filter(new Function<String, Boolean>() {
            public Boolean call(String arg0) throws Exception {
                if(arg0.contains("123") || arg0.contains("456")){
                    return true;
                }
                return false;
            }
        });

        JavaPairRDD<String, Integer> pairRDD = flatMapRDD
                .mapToPair(new PairFunction<String, String, Integer>() {
                    public Tuple2<String, Integer> call(String arg0)
                            throws Exception {
                        return new Tuple2<String, Integer>(arg0, 1);
                    }
                });

        mapRDD.saveAsTextFile(outputPath + "/map");
        flatMapRDD.saveAsTextFile(outputPath + "/flatMap");
        filterRDD.saveAsTextFile(outputPath + "/filter");
        pairRDD.saveAsTextFile(outputPath + "/mapPair");
    }
}
