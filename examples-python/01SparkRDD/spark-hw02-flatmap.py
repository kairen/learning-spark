

from pyspark import SparkContext
sc = SparkContext("local", "Simple App")
textFile = sc.textFile("hdfs:/spark/hw/test.txt")
numBs = textFile.flatMap(lambda s: s.split(',')).map(lambda s:print(s)).collect()
