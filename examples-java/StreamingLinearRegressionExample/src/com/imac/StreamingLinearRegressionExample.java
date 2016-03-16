package com.imac.test;


import org.apache.spark.SparkConf;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.api.java.function.PairFunction;
import org.apache.spark.mllib.clustering.StreamingKMeans;
import org.apache.spark.mllib.linalg.Vector;
import org.apache.spark.mllib.linalg.Vectors;
import org.apache.spark.mllib.regression.LabeledPoint;
import org.apache.spark.streaming.Durations;
import org.apache.spark.streaming.api.java.JavaDStream;
import org.apache.spark.streaming.api.java.JavaStreamingContext;

import scala.Tuple2;

public class StreamingKMeansExample  {

	public static void main(String[] args) {
		  if (args.length != 2) {
			System.err.println("Usage: StreamingLinearRegressionExample <trainingDir> <testDir>");
			System.exit(1);
		  }

		  SparkConf conf = new SparkConf().setAppName("StreamingLinearRegressionExample");
				  JavaStreamingContext ssc = new JavaStreamingContext(conf, Durations.seconds(1));

		    JavaDStream<Vector> trainingData = ssc.textFileStream(args[0]).map(new Function<String, Vector>() {
				public Vector call(String line) throws Exception {
					String[] parts = line.split(",");
					String[] features = parts[1].split(" ");
					double[] v = new double[features.length];
					for (int i = 0; i < features.length - 1; i++)
						v[i] = Double.parseDouble(features[i]);
					return Vectors.dense(v);
				}
			}).cache();
		    
		    System.out.println("train "+trainingData.count());
					
		    JavaDStream<LabeledPoint> testData = ssc.textFileStream(args[1]).map(new Function<String, LabeledPoint>() {
				public LabeledPoint call(String line) throws Exception {
					String[] parts = line.split(",");
					String[] features = parts[1].split(" ");
					double[] v = new double[features.length];
					for (int i = 0; i < features.length - 1; i++)
						v[i] = Double.parseDouble(features[i]);
					return new LabeledPoint(Double.parseDouble(parts[0]), Vectors.dense(v));
				}
			});
		    
		    int numFeatures = 2;
		    StreamingLinearRegressionWithSGD model = new StreamingLinearRegressionWithSGD()
		      .setInitialWeights(Vectors.zeros(numFeatures));
		    model.trainOn(trainingData);
		
		     JavaPairDStream<Double, Double> predic_result = model.predictOnValues(testData.mapToPair(new PairFunction<LabeledPoint, Double, Vector>() {
				public Tuple2<Double, Vector> call(LabeledPoint arg0)
						throws Exception {
					return new Tuple2<Double, Vector>(arg0.label(), arg0.features());
				}
			}));
			predic_result.print();
			predic_result.foreach(new Function<JavaPairRDD<Double,Double>, Void>() {
				public Void call(JavaPairRDD<Double, Double> arg0) throws Exception {
					if(!arg0.isEmpty()){
						Double MSE = new JavaDoubleRDD(arg0.map(new Function<Tuple2<Double,Double>, Object>() {
							public Object call(Tuple2<Double, Double> pair)
									throws Exception {
								return Math.pow(pair._1() - pair._2(), 2.0);
							}
						}).rdd()).mean();
						
						System.out.println("training Mean Squared Error = " + MSE);
					}
					
					return null;
				}
			});
		    
		    ssc.start();
		    ssc.awaitTermination();

		    ssc.stop();
	}
}
