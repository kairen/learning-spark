

from pyspark import SparkContext
sc = SparkContext("local", "Simple App")
textFile = sc.textFile("hdfs:/spark/hw/test.txt")

numBs = textFile.map(lambda s: s.split(',')).map(lambda x:print(x[0])).collect()

