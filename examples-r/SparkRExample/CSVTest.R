# 載入 SparkR library
library(SparkR)

# 把 SparkContext 和 SQLContext 初始化
sc <- sparkR.init(appName="SparkR-DataFrame-example")
sqlContext <- sparkRSQL.init(sc)

# 因為載入 CSV 後可能會沒有資料表欄位，需要先設定 CSV 資料載入後的欄位格式及名稱
csvSchema <- structType(structField("name", "string"), structField("age", "string"))

# 可透過 read.df API 將本地端 CSV 資料讀取後轉換成 SparkSQL DataFrame
peopleDF2 <- read.df(sqlContext, "file:///opt/spark/examples/src/main/resources/people.txt", source = "com.databricks.spark.csv", schema = csvSchema)

#印出 SparkSQL DataFrame API 的資料格式
print(peopleDF2)

#印出 peopleDF 資料內容
collect(peopleDF2)

# 需要把 DF 格式資料轉為二維資料表
registerTempTable(peopleDF2, "people")

# 藉由 sqlContext 可以使用 SQL 語法來做關聯式查詢
teenagers <- sql(sqlContext, "SELECT name FROM people ORDER BY age ASC")

# 利用 collect 去取得轉換二維資料表為 data.frame 格式的結果
teenagersLocalDF <- collect(teenagers)

# 把資料集中的 teenagers 印出
print(teenagersLocalDF)

# 停止 SparkContext (最後必定要呼叫)
sparkR.stop()
