package com.imac;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.PairFunction;
import org.apache.spark.api.java.function.VoidFunction;
import org.apache.spark.graphx.Edge;
import org.apache.spark.graphx.EdgeRDD;
import org.apache.spark.graphx.Graph;
import org.apache.spark.graphx.GraphLoader;
import org.apache.spark.graphx.PartitionStrategy;
import org.apache.spark.graphx.VertexRDD;
import org.apache.spark.graphx.lib.PageRank;
import org.apache.spark.graphx.lib.TriangleCount;
import org.apache.spark.storage.StorageLevel;

import scala.Tuple2;

public class TestTriangleCount {

	public static void main(String[] args) {

		SparkConf conf = new SparkConf();
		conf.setAppName("GraphX");

		JavaSparkContext sc = new JavaSparkContext(conf);

		/**
		 * 載入資料 followers.txt
		  2 1
			4 1
			1 2
			6 3
			7 3
			7 6
			6 7
			3 7
		 */
		Graph<Object, Object> graph = GraphLoader.edgeListFile(sc.sc(), args[0], true, 1, StorageLevel.MEMORY_AND_DISK_SER(), StorageLevel.MEMORY_AND_DISK_SER())
					.partitionBy(PartitionStrategy.RandomVertexCut$.MODULE$);

		//邊
		EdgeRDD<Object> edge = graph.edges();

		//點
		VertexRDD<Object> vertices = graph.vertices();

		//查看 邊的內容
		edge.toJavaRDD().foreach(new VoidFunction<Edge<Object>>() {
			public void call(Edge<Object> arg0) throws Exception {
				System.out.println(arg0.toString());
			}
		});

		//查看 點的內容
		vertices.toJavaRDD().foreach(new VoidFunction<Tuple2<Object,Object>>() {
			public void call(Tuple2<Object, Object> arg0) throws Exception {
				System.out.println(arg0.toString());
			}
		});

		// 執行 TriangleCount 演算法
		Graph<Object, Object> triCounts = TriangleCount.run(graph, graph.vertices().vdTag(), graph.vertices().vdTag());


		//邊
		EdgeRDD<Object> edgeRDD = triCounts.edges();
		//點
		VertexRDD<Object> vertexRDD = triCounts.vertices();

		//查看執行完演算法的邊
		edgeRDD.toJavaRDD().foreach(new VoidFunction<Edge<Object>>() {
			public void call(Edge<Object> arg0) throws Exception {
				System.out.println(arg0.toString());
			}
		});

		//查看執行完演算法的點
		vertexRDD.toJavaRDD().foreach(new VoidFunction<Tuple2<Object,Object>>() {
			public void call(Tuple2<Object, Object> arg0) throws Exception {
				System.out.println(arg0.toString());
			}
		});

		//將 點的RDD 轉換成 JavaPairRDD ，等等與使用者名稱Join
		JavaPairRDD<Long, String> rank = vertexRDD.toJavaRDD().mapToPair(new PairFunction<Tuple2<Object,Object>,Long, String>() {
			public Tuple2<Long, String> call(Tuple2<Object, Object> arg0)
					throws Exception {
				return new Tuple2<Long, String>((Long)arg0._1(),arg0._2()+"");
			}
		});

		/**
		 * 載入使用者名稱
		  1,BarackObama,Barack Obama
			2,ladygaga,Goddess of Love
			3,jeresig,John Resig
			4,justinbieber,Justin Bieber
			6,matei_zaharia,Matei Zaharia
			7,odersky,Martin Odersky
			8,anonsys
		 */

		JavaRDD<String> input = sc.textFile(args[1]);

		//將資料轉換成 可Join的JavaPairRDD
		JavaPairRDD<Long, String> userRDD = input.mapToPair(new PairFunction<String, Long, String>() {
			public Tuple2<Long, String> call(String arg0) throws Exception {
				String [] split = arg0.split(",");
				return new Tuple2<Long, String>(Long.parseLong(split[0]),split[1]);
			}
		});

		//輸出使用者 和 排名分數
		JavaPairRDD<String, String>  ranksByUsername  = userRDD.join(rank).mapToPair(new PairFunction<Tuple2<Long,Tuple2<String,String>>, String, String>() {
			public Tuple2<String, String> call(
					Tuple2<Long, Tuple2<String, String>> arg0) throws Exception {
				return new Tuple2<String, String>(arg0._2()._1(),arg0._2()._2());
			}
		});

		ranksByUsername.sortByKey(false).foreach(new VoidFunction<Tuple2<String,String>>() {
			public void call(Tuple2<String, String> arg0) throws Exception {
				System.out.println(arg0);
			}
		});
	}

}
