package com.imac.test;

import java.util.ArrayList;
import java.util.List;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.Function2;
import org.apache.spark.api.java.function.PairFlatMapFunction;
import org.apache.spark.api.java.function.PairFunction;

import scala.Tuple2;

public class Main {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		if (args.length < 2) {
			System.exit(1);
		}
		
		SparkConf conf = new SparkConf();
		conf.setAppName("RankSpark");
		conf.setMaster("yarn-cluster");
		
		JavaSparkContext sc = new JavaSparkContext(conf);
		JavaRDD<String> file = sc.textFile(args[0]);
		
		JavaPairRDD<String, Integer> flatMapToPair = file.flatMapToPair(new PairFlatMapFunction<String, String, Integer>() {

			public Iterable<Tuple2<String, Integer>> call(String arg0)
					throws Exception {
				int total = 0;
				String plistStr = arg0.split("plist=")[1];
				String[] plist = plistStr.split(",");
				
				ArrayList<Tuple2<String, Integer>> arrayList = new ArrayList<Tuple2<String,Integer>>();
				for (int i = 0; i < plist.length; i+=3) {
					total = Integer.parseInt(plist[i+1]) * Integer.parseInt(plist[i+2]);
					arrayList.add(new Tuple2<String, Integer>(plist[i],total));
				}
				return arrayList;
			}
		});
		
		JavaPairRDD<String, Integer> reduceByKey = flatMapToPair.reduceByKey(new Function2<Integer, Integer, Integer>() {
			
			public Integer call(Integer arg0, Integer arg1) throws Exception {
				return arg0+arg1;
			}
		});
		
		JavaPairRDD<Integer, String> resultSort = reduceByKey.flatMapToPair(new PairFlatMapFunction<Tuple2<String,Integer>, Integer, String>() {

			public Iterable<Tuple2<Integer, String>> call(
					Tuple2<String, Integer> arg0) throws Exception {
				ArrayList<Tuple2<Integer, String>> arrayList
				=new ArrayList<Tuple2<Integer, String>>();
				arrayList.add(new Tuple2<Integer, String>(arg0._2, arg0._1));
				return arrayList;
			}
		});
		
		JavaPairRDD<Integer, String> sort = resultSort.sortByKey(false);
		
		//取前20筆
		List<String> list = sort.values().take(20);
		
		List<String> rankList = new ArrayList();
		
		for (int i = 1; i <= list.size(); i++) {
			if (i < 10) {
				rankList.add("0"+ i + " " + list.get(i-1));
			}else {
				rankList.add(i + " " + list.get(i-1));
			}
		}
		
		//將list轉換成JavaRDD(list, 印出幾筆資料)
		JavaRDD<String> result = sc.parallelize(rankList, 1);
		result.saveAsTextFile(args[1]);
	}

}
