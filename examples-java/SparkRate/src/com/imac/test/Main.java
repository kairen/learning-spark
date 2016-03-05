package com.imac.test;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;
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
		conf.setAppName("RateSpark");
//		conf.setMaster("yarn-cluster");
		
		JavaSparkContext sc = new JavaSparkContext(conf);
		JavaRDD<String> file = sc.textFile(args[0]);
		
		//過濾不必要資料
		JavaRDD<String> filter =  file.filter(new Function<String, Boolean>() {
			
			public Boolean call(String arg0) throws Exception {
				String[] arrayStr = StringSplite(arg0, ",");
				if ( ChangeValue(arrayStr[0]) <11 && ChangeValue(arrayStr[1]) <11 && ChangeValue(arrayStr[2]) > 2) {
					return true;
				}
				return false;
			}
		});
		
		//因為要排序()
		JavaPairRDD<Integer, String> mapToPair = filter.mapToPair(new PairFunction<String, Integer, String>() {

			public Tuple2<Integer, String> call(String arg0) throws Exception {
				String[] arrayStr = StringSplite(arg0, ",");
				return new Tuple2<Integer, String>(Integer.parseInt(arrayStr[2]), "User "+arrayStr[0]+" 評價 "+arrayStr[1]+" 為 "+arrayStr[2]);
			}
		});
		
		JavaPairRDD<Integer, String> sort = mapToPair.sortByKey(false);
		sort.values().saveAsTextFile(args[1]);
	}
	
	

	private static String[] StringSplite(String arg0, String spliteStr) {
		return arg0.split(spliteStr);
	}
	
	private static int ChangeValue(String str) {
		return Integer.parseInt(str);
	}
}
