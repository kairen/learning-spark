package com.imac.test;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.FlatMapFunction;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.PairFunction;
import org.apache.spark.mllib.linalg.Vectors;
import org.apache.spark.mllib.regression.LabeledPoint;
import org.apache.spark.mllib.tree.GradientBoostedTrees;
import org.apache.spark.mllib.tree.configuration.BoostingStrategy;
import org.apache.spark.mllib.tree.model.GradientBoostedTreesModel;

import scala.Tuple2;
import scala.Tuple3;

public class TestGradientBoostedTrees {
	

	public static void main(String[] args) {
		SparkConf conf = new SparkConf();
		conf.setAppName("Test");
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		
		JavaRDD<String> rawRDD = sc.textFile(args[0]);
		JavaRDD<String>[] slice = rawRDD.randomSplit(new double[] { 0.8, 0.2 });

		JavaRDD<String> train_rdd = slice[0];
		JavaRDD<String> test_rdd = slice[1];

		train_rdd.cache();
		test_rdd.cache();

		JavaRDD<Tuple3<String, List<String>, List<String>>> featrueRDD = train_rdd.map(new Function<String, Tuple3<String, List<String>, List<String>>>() {
			public Tuple3<String, List<String>, List<String>> call(String arg0) throws Exception {
				String[] token = arg0.split(",");
				String catkey = token[0] + "::" + token[1];
				List<String> catfeatures = new ArrayList<String>();
				for (int i = 5; i <= 14; i++) {
					catfeatures.add(token[i]);
				}

				List<String> numericalfeatures = new ArrayList<String>();
				for (int i = 15; i < token.length; i++) {
					numericalfeatures.add(token[i]);
				}

				return new Tuple3<String, List<String>, List<String>>(catkey, catfeatures, numericalfeatures);
			}
		});
		

		JavaRDD<ArrayList<Tuple2<Integer, String>>> train_cat_rdd = featrueRDD
				.map(new Function<Tuple3<String, List<String>, List<String>>, ArrayList<Tuple2<Integer, String>>>() {
					public ArrayList<Tuple2<Integer, String>> call(Tuple3<String, List<String>, List<String>> arg0) throws Exception {
						return parseCatFeatures(arg0._2());
					}
				});
		

		final Map<Tuple2<Integer, String>, Long> oheMap = train_cat_rdd.flatMap(new FlatMapFunction<ArrayList<Tuple2<Integer, String>>, Tuple2<Integer, String>>() {
			public Iterable<Tuple2<Integer, String>> call(ArrayList<Tuple2<Integer, String>> arg0) throws Exception {
				return arg0;
			}
		}).distinct().zipWithIndex().collectAsMap();
		

		JavaRDD<LabeledPoint> ohe_train_rdd = featrueRDD.map(new Function<Tuple3<String, List<String>,List<String>>, LabeledPoint>() {
			public LabeledPoint call(Tuple3<String, List<String>,List<String>> arg0) throws Exception {
				ArrayList<Tuple2<Integer, String>> cat_features_indexed = parseCatFeatures(arg0._2());
				ArrayList<Double> cat_feature_ohe = new ArrayList<>();
				for (Tuple2<Integer, String> v : cat_features_indexed) {
					if (oheMap.containsKey(v)) {
						double b = (double) oheMap.get(v);
						cat_feature_ohe.add(b);
					} else {
						cat_feature_ohe.add(0.0);
					}
				}
			
				Object[] aa = cat_feature_ohe.toArray();
				
				double[] dd = new double[aa.length];
				for (int i = 0; i < aa.length; i++) {
					dd[i] = (double) aa[i];
				}
				
				ArrayList<String> numerical_features_dbl = new ArrayList<>();
				for(String v : arg0._3()){
					if(Integer.parseInt(v)<0){
						numerical_features_dbl.add("0");
					}else{
						numerical_features_dbl.add(v);
					}
				}
				Object[] num_obj = numerical_features_dbl.toArray();
				double[] num_double = new double[num_obj.length];
				for (int i = 0; i < num_double.length; i++) {
					num_obj[i] = (double) num_double[i];
				}
				
				double [] features=  new double [num_double.length];
				for (int i = 0; i < num_double.length; i++) {
					features[i] = dd[i]+num_double[i];
				}
				return new LabeledPoint(Double.parseDouble(arg0._1().split("::")[1]), Vectors.dense(features));
			}
		});
		
		System.out.println("GradientBoostedTreesModel.....");
		BoostingStrategy boostingStrategy = BoostingStrategy.defaultParams("Classification");
		boostingStrategy.setNumIterations(10); 
		boostingStrategy.getTreeStrategy().setNumClasses(2);
		boostingStrategy.getTreeStrategy().setMaxDepth(10);

		final GradientBoostedTreesModel model = GradientBoostedTrees.train(ohe_train_rdd, boostingStrategy);
		
//		model.save(sc.sc(), "/GradientBoostedTreesModel");
		
		// test....
		System.out.println("Testing.....");
		
//		final GradientBoostedTreesModel model = GradientBoostedTreesModel.load(sc.sc(), "/GradientBoostedTreesModel");
		
		JavaRDD<Tuple3<String, List<String>, List<String>>> test_raw_data = test_rdd.map(new Function<String, Tuple3<String, List<String>, List<String>>>() {
			public Tuple3<String, List<String>, List<String>> call(String arg0) throws Exception {
				String[] token = arg0.split(",");
				String catkey = token[0] + "::" + token[1];
				List<String> catfeatures = new ArrayList<String>();
				for (int i = 5; i <= 14; i++) {
					catfeatures.add(token[i]);
				}

				List<String> numericalfeatures = new ArrayList<String>();
				for (int i = 15; i < token.length; i++) {
					numericalfeatures.add(token[i]);
				}

				return new Tuple3<String, List<String>, List<String>>(catkey, catfeatures, numericalfeatures);
			}
		});

		JavaRDD<LabeledPoint> testData = test_raw_data.map(new Function<Tuple3<String,List<String>, List<String>>, LabeledPoint>() {
			public LabeledPoint call(Tuple3<String,List<String>, List<String>> arg0) throws Exception {
				ArrayList<Tuple2<Integer, String>> cat_features_indexed = parseCatFeatures(arg0._2());
				ArrayList<Double> cat_feature_ohe = new ArrayList<>();
				for (Tuple2<Integer, String> v : cat_features_indexed) {
					if (oheMap.containsKey(v)) {
						double b = (double) oheMap.get(v);
						cat_feature_ohe.add(b);
					} else {
						cat_feature_ohe.add(0.0);
					}
				}
			
				Object[] aa = cat_feature_ohe.toArray();
				
				double[] dd = new double[aa.length];
				for (int i = 0; i < aa.length; i++) {
					dd[i] = (double) aa[i];
				}
				
				ArrayList<String> numerical_features_dbl = new ArrayList<>();
				for(String v : arg0._3()){
					if(Integer.parseInt(v)<0){
						numerical_features_dbl.add("0");
					}else{
						numerical_features_dbl.add(v);
					}
				}
				Object[] num_obj = numerical_features_dbl.toArray();
				double[] num_double = new double[num_obj.length];
				for (int i = 0; i < num_double.length; i++) {
					num_obj[i] = (double) num_double[i];
				}
				
				double [] features=  new double [num_double.length];
				for (int i = 0; i < num_double.length; i++) {
					features[i] = dd[i]+num_double[i];
				}
				return new LabeledPoint(Double.parseDouble(arg0._1().split("::")[1]), Vectors.dense(features));
			}
		});

		JavaPairRDD<Double, Double> predictionAndLabel = testData.mapToPair(new PairFunction<LabeledPoint, Double, Double>() {
			public Tuple2<Double, Double> call(LabeledPoint p) {
				return new Tuple2<Double, Double>(model.predict(p.features()), p.label());
			}
		});

		Double testErr = 1.0 * predictionAndLabel.filter(new Function<Tuple2<Double, Double>, Boolean>() {
			public Boolean call(Tuple2<Double, Double> pl) {
				System.out.println(pl._1()+"		"+pl._2());
				return !pl._1().equals(pl._2());
			}
		}).count() / testData.count();

		System.out.println("Test Error: " + testErr);
		System.out.println("Learned classification GBT model:\n" + model.toDebugString());
	}

	public static ArrayList<Tuple2<Integer, String>> parseCatFeatures(List<String> list){
		ArrayList<Tuple2<Integer, String>> arrayList = new ArrayList<>();
		for(int i=0 ; i <list.size();i++){
			arrayList.add(new Tuple2<Integer, String>(i, list.get(i)));
		}
		
		return arrayList;
	}
}
