
from pyspark import SparkContext
sc = SparkContext("local", "Simple App")
textFile = sc.textFile("hdfs:/spark/hw/test.txt")
numBs = textFile.flatMap(lambda s: s.split(','))\
	.filter(lambda line:"123"in line or "456" in line)\
	.map(lambda w:print(w)).collect()
