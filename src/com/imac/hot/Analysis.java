package com.imac.hot;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.*;
import scala.Tuple2;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by kairenbai on 2015/12/14.
 */
public class Analysis {

    public static void main(final String []argv) {

        if (argv.length != 2) {
            System.err.printf("Usage: %s [generic options] <input> <output>\n",
                    Analysis.class.getSimpleName());
            return;
        }

        String inputPath = argv[0];
        String outputPath = argv[1];

        SparkConf conf = new SparkConf().setAppName("SparkExample").setMaster("yarn-cluster");
        JavaSparkContext sparkContext = new JavaSparkContext(conf);

        // TODO : MapReduce data ...
        JavaPairRDD<String, Integer> resultPairRDD = sparkContext.textFile(inputPath, 1)
                .flatMapToPair(new PairFlatMapFunction<String, String, Integer>() {
                    public Iterable<Tuple2<String, Integer>> call(String arg0)
                            throws Exception {
                        ArrayList<Tuple2<String, Integer>> arrayList = new ArrayList<Tuple2<String, Integer>>();
                        String[] values = arg0.split("plist=")[1].split(",");

                        for (int i = 0; i < values.length; i += 3) {
                            int sum = Integer.parseInt(values[i + 1]) * Integer.parseInt(values[i + 2]);
                            arrayList.add(new Tuple2<String, Integer>(values[i], sum));
                        }
                        return arrayList;
                    }
                }).reduceByKey(new Function2<Integer, Integer, Integer>() {
                    @Override
                    public Integer call(Integer num1, Integer num2) throws Exception {
                        return num1 + num2;
                    }
                });

        // TODO : Get Top 20
        List<Tuple2<Integer, String>> results = resultPairRDD
                .mapToPair(new PairFunction<Tuple2<String, Integer>, Integer, String>() {
                    @Override
                    public Tuple2<Integer, String> call(Tuple2<String, Integer> tuple) throws Exception {
                        return tuple.swap();
                    }
                }).sortByKey(false).take(20);

        // TODO : save to HDFS
        ArrayList<String> arrayList = new ArrayList<String>();

        int i = 1;
        for (Tuple2<Integer, String> tuple : results) {
            arrayList.add(String.format("%02d", i) + "," + tuple._2);
            i++;
        }
        JavaRDD<String> resultRDD = sparkContext.parallelize(arrayList, 1);

        resultRDD.saveAsTextFile(outputPath);
    }
}
