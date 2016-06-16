package com.imac.test;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;
import org.apache.spark.ml.feature.HashingTF;
import org.apache.spark.ml.feature.IDF;
import org.apache.spark.ml.feature.IDFModel;
import org.apache.spark.ml.feature.Tokenizer;
import org.apache.spark.mllib.classification.NaiveBayes;
import org.apache.spark.mllib.classification.NaiveBayesModel;
import org.apache.spark.mllib.linalg.Vector;
import org.apache.spark.mllib.linalg.Vectors;
import org.apache.spark.mllib.regression.LabeledPoint;
import org.apache.spark.sql.DataFrame;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.RowFactory;
import org.apache.spark.sql.SQLContext;
import org.apache.spark.sql.types.DataTypes;
import org.apache.spark.sql.types.StructField;
import org.apache.spark.sql.types.StructType;

import scala.Tuple2;

public class TestNaiveBayes {

	public static void main(String[] args) {
		SparkConf conf = new SparkConf();
		conf.setAppName("TestNaiveBayes");

		JavaSparkContext sc = new JavaSparkContext(conf);
		SQLContext sqlContext = new SQLContext(sc);

		JavaRDD<String> srcRDD = sc.textFile(args[0]);
		JavaRDD<Row> rowRDD = srcRDD.map(new Function<String, Row>() {
			public Row call(String arg0) throws Exception {
				String [] tokens = arg0.split(",");
				return RowFactory.create(tokens[0],tokens[1]);
			}
		});

		JavaRDD<Row>[] splitRDD = rowRDD.randomSplit(new double [] {0.7,0.3});

		JavaRDD<Row> trainRDD = splitRDD[0].cache();
		JavaRDD<Row> testRDD = splitRDD[1].cache();

		DataFrame trainDF = sqlContext.createDataFrame(trainRDD, createStructType());

		Tokenizer tokenizer = new Tokenizer().setInputCol("text").setOutputCol("words");
		DataFrame wordsData = tokenizer.transform(trainDF);
		wordsData.printSchema();

		System.out.println(wordsData.select("category","text","words").take(1)[0]);

		HashingTF hashingTF = new HashingTF().setNumFeatures(500000).setInputCol("words").setOutputCol("rawFeatures");
		DataFrame featurizedData = hashingTF.transform(wordsData);
		featurizedData.printSchema();
		System.out.println(featurizedData.select("category","words","rawFeatures").take(1)[0]);


		IDF idf = new IDF().setInputCol("rawFeatures").setOutputCol("features");
		IDFModel idfModel = idf.fit(featurizedData);
		DataFrame rescaledData = idfModel.transform(featurizedData);
		rescaledData.printSchema();

		System.out.println(rescaledData.select("category","features").take(1)[0]);


		JavaRDD<LabeledPoint> trainDataRdd = rescaledData.select("category","features").toJavaRDD().map(new Function<Row, LabeledPoint>() {
			public LabeledPoint call(Row arg0) throws Exception {
				String outputString =arg0.get(1).toString();
				String total = outputString.substring(1, outputString.indexOf(","));
				String key = outputString.substring(outputString.indexOf("[")+1, outputString.indexOf("]"));
				String value = outputString.substring(outputString.lastIndexOf("[")+1, outputString.lastIndexOf("]"));

				HashMap<Integer, Double> masHashMap = new HashMap<>();

				String [] key_token = key.split(",");
				String [] value_token = value.split(",");

				for(int i=0; i<key_token.length; i++){
					masHashMap.put(Integer.parseInt(key_token[i]), Double.parseDouble(value_token[i]));
				}

				double [] vectors = new double [Integer.parseInt(total)];
				for(int i=0 ;i<vectors.length;i++){
					if(isContain(key_token,i)){
					  vectors[i] = masHashMap.get(i);
					}else{
					  vectors[i] =0.0;
					}
				}
				return new LabeledPoint(Double.parseDouble(arg0.get(0).toString()),Vectors.dense(vectors));
			}
		});

		for(LabeledPoint v : trainDataRdd.take(1)){
			Vector vv = v.features();
			for(int i=0; i<vv.size(); i++){
				if(vv.apply(i)!=0.0)
				System.out.println(i+"  "+vv.apply(i));
			}
		}

	    final NaiveBayesModel model = NaiveBayes.train(trainDataRdd.rdd(), 1.0);

	    // test data
	    DataFrame testDF = sqlContext.createDataFrame(testRDD,createStructType());
	    DataFrame testwordsData = tokenizer.transform(testDF);
	    DataFrame testfeaturizedData = hashingTF.transform(testwordsData);
	    DataFrame testrescaledData = idfModel.transform(testfeaturizedData);
	    JavaRDD<LabeledPoint> testDataRdd  =testrescaledData.select("category","features").toJavaRDD().map(new Function<Row, LabeledPoint>() {
			public LabeledPoint call(Row arg0) throws Exception {
				String outputString =arg0.get(1).toString();
				String total = outputString.substring(1, outputString.indexOf(","));
				String key = outputString.substring(outputString.indexOf("[")+1, outputString.indexOf("]"));
				String value = outputString.substring(outputString.lastIndexOf("[")+1, outputString.lastIndexOf("]"));

				HashMap<Integer, Double> masHashMap = new HashMap<>();

				String [] key_token = key.split(",");
				String [] value_token = value.split(",");

				for(int i=0; i<key_token.length; i++){
					masHashMap.put(Integer.parseInt(key_token[i]), Double.parseDouble(value_token[i]));
				}

				double [] vectors = new double [Integer.parseInt(total)];
				for(int i=0 ;i<vectors.length;i++){
					if(isContain(key_token,i)){
					  vectors[i] = masHashMap.get(i);
					}else{
					  vectors[i] =0.0;
					}
				}
				return new LabeledPoint(Double.parseDouble(arg0.get(0).toString()),Vectors.dense(vectors));
			}
		});

	    JavaRDD<Tuple2<Double, Double>> testpredictionAndLabel = testDataRdd.map(new Function<LabeledPoint, Tuple2<Double,Double>>() {
			public Tuple2<Double, Double> call(LabeledPoint arg0) throws Exception {
				return new Tuple2<Double, Double>(model.predict(arg0.features()), arg0.label());
			}
		});

	    double testaccuracy = 1.0 * testpredictionAndLabel.filter(new Function<Tuple2<Double,Double>, Boolean>() {
			public Boolean call(Tuple2<Double, Double> arg0) throws Exception {
				return ((arg0._1-arg0._2) == 0.0)?true:false;
			}
		}).count()/testDataRdd.count();

	  System.out.println("Accuracy  : "+testaccuracy);
		sc.stop();
	}

	private static StructType createStructType() {
		List<StructField> fields = new ArrayList<>();
		fields.add(DataTypes.createStructField("category", DataTypes.StringType, true));
	    fields.add(DataTypes.createStructField("text", DataTypes.StringType, true));
	    StructType schema = DataTypes.createStructType(fields);
		return schema;
	}

	private static  boolean isContain(String [] token , int key){
		for(String v : token){
			if(Integer.parseInt(v) == key)
				return true;
		}
		return false;
	}

}
