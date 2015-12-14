package com.imac.example;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;

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
        JavaRDD<String> file = sparkContext.textFile(inputPath, 1);

        JavaRDD<String> map = file.map(new Function<String, String>() {
            public String call(String arg0) throws Exception {
                return arg0.split(",")[0];
            }
        });

        JavaRDD<String> flatMapFile = file.flatMap(new FlatMapFunction<String, String>() {
            public Iterable<String> call(String arg0)
                    throws Exception {
                return Arrays.asList(arg0.split(","));
            }
        });

        map.saveAsTextFile(outputPath);
        flatMapFile.saveAsTextFile(outputPath+"/flatmap");
    }
}
