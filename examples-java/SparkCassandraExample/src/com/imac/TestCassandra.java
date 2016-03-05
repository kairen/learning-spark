package com.imac;

import com.datastax.spark.connector.japi.CassandraRow;
import com.google.common.base.Objects;
import org.apache.hadoop.util.StringUtils;
import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.JavaSparkContext;
import org.apache.spark.api.java.function.Function;

import java.io.Serializable;
import java.util.Arrays;
import java.util.Date;
import java.util.List;

import static com.datastax.spark.connector.japi.CassandraJavaUtil.*;

/**
 * This Spark application demonstrates how to use Spark Cassandra Connector with
 * Java.
 * <p/>
 * In order to run it, you will need to run Cassandra database, and create the
 * following keyspace, table and secondary index:
 * <p/>
 * 
 * <pre>
 * CREATE KEYSPACE test WITH REPLICATION = {'class': 'SimpleStrategy', 'replication_factor': 1};
 * 
 * CREATE TABLE test.people (
 *      id          INT,
 *      name        TEXT,
 *      birth_date  TIMESTAMP,
 *      PRIMARY KEY (id)
 * );
 * 
 * CREATE INDEX people_name_idx ON test.people(name);
 * </pre>
 */
public class TestCassandra implements Serializable {

	public static void main(String[] args) {
		
		// just an initialisation of Spark Context
		SparkConf conf = new SparkConf();
		conf.set("spark.cassandra.connection.host", args[0]);
		conf.setAppName("TestCassandra");
		JavaSparkContext sc = new JavaSparkContext(conf);
		
		// here we are going to save some data to Cassandra...
		List<Person> people = Arrays.asList(Person.newInstance(1, "John"), Person.newInstance(2, "Anna"), Person.newInstance(3, "Andrew"));
		JavaRDD<Person> rdd = sc.parallelize(people);
		javaFunctions(rdd).writerBuilder("test", "people",mapToRow(Person.class)).saveToCassandra();
		
		// use case: we want to read that data as an RDD of CassandraRows and
		// convert them to strings...
		JavaRDD<String> cassandraRowsRDD = javaFunctions(sc).cassandraTable("test", "people").map(new Function<CassandraRow, String>() {
			public String call(CassandraRow cassandraRow) throws Exception {
				return cassandraRow.toString();
			}
		});
		System.out.println("Data as CassandraRows: \n" + StringUtils.join("\n", cassandraRowsRDD.collect()));

		// use case: we want to read that data as an RDD of Person beans and
		// also convert them to strings...
		JavaRDD<String> rdd2 = javaFunctions(sc).cassandraTable("test", "people", mapRowTo(Person.class)).map(new Function<Person, String>() {
			@Override
			public String call(Person person) throws Exception {
				return person.toString();
			}
		});
		System.out.println("Data as Person beans: \n" + StringUtils.join("\n", rdd2.collect()));

		// use case: we want to filter rows on the database side with use of the
		// where clause
		JavaRDD<String> rdd3 = javaFunctions(sc).cassandraTable("test", "people", mapRowTo(Person.class)).where("name=?", "Anna").map(new Function<Person, String>() {
			@Override
			public String call(Person person) throws Exception {
				return person.toString();
			}
		});
		System.out.println("Data filtered by the where clause (name='Anna'): \n" + StringUtils.join("\n", rdd3.collect()));

		// use case: we want to explicitly set a projection on the column set
		JavaRDD<String> rdd4 = javaFunctions(sc).cassandraTable("test", "people").select("id").map(new Function<CassandraRow, String>() {
			@Override
			public String call(CassandraRow cassandraRow) throws Exception {
				return cassandraRow.toString();
			}
		});
		System.out.println("Data with only 'id' column fetched: \n" + StringUtils.join("\n", rdd4.collect()));

		sc.stop();
	}
}
