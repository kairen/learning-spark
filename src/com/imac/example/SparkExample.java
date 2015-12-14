package com.imac.example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.PairFlatMapFunction;
import org.apache.spark.api.java.function.PairFunction;
import scala.Tuple2;

import java.util.ArrayList;
import java.util.Arrays;

/**
 * Created by kairenbai on 2015/12/11.
 */
public class SparkExample {

    public static void main(final String []argv) {

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

        JavaPairRDD<String, Integer> mapPairRDD = flatMapRDD
                .mapToPair(new PairFunction<String, String, Integer>() {
                    public Tuple2<String, Integer> call(String arg0)
                            throws Exception {
                        return new Tuple2<String, Integer>(arg0, 1);
                    }
                });

        JavaPairRDD<String, Integer> flatMapPairRDD = fileRDD
                .flatMapToPair(new PairFlatMapFunction<String, String, Integer>() {
                    public Iterable<Tuple2<String, Integer>> call(String arg0)
                            throws Exception {
                        ArrayList<Tuple2<String, Integer>> arrayList
                                = new ArrayList<Tuple2<String, Integer>>();
                        String []values = arg0.split(",");
                        int sum = 0;
                        for(String str : values) {
                            if (isInteger(str))
                                sum += Integer.parseInt(str);
                        }
                        arrayList.add(new Tuple2<String, Integer>(values[0], sum));
                        return arrayList;
                    }
                });

        mapRDD.saveAsTextFile(outputPath + "/map");
        flatMapRDD.saveAsTextFile(outputPath + "/flatMap");
        filterRDD.saveAsTextFile(outputPath + "/filter");
        mapPairRDD.saveAsTextFile(outputPath + "/mapPair");
        flatMapPairRDD.saveAsTextFile(outputPath + "/flatMapPair");
    }

    public static boolean isInteger(String input) {
        try {
            Integer.parseInt(input);
            return true;
        }
        catch(Exception e) {
            return false;
        }
    }
}
