# 載入 SparkR library
library(SparkR)

# 把 SparkContext 和 SQLContext 初始化
sc <- sparkR.init(appName="SparkR-DataFrame-example")
sqlContext <- sparkRSQL.init(sc)


# 可透過 read.df API 將本地端 JSON 資料讀取後轉換成 SparkSQL DataFrame
peopleDF <- read.df(sqlContext, "file:///opt/spark/examples/src/main/resources/people.json", source = "json")

#印出 SparkSQL DataFrame API 的資料格式
print(peopleDF)

#印出 peopleDF 資料內容
collect(peopleDF)

# 需要把 DF 格式資料轉為二維資料表
registerTempTable(peopleDF, "people")

# 藉由 sqlContext 可以使用 SQL 語法來做關聯式查詢
teenagers <- sql(sqlContext, "SELECT name FROM people WHERE age >= 13 AND age <= 19")

# 利用 collect 去取得轉換二維資料表為 data.frame 格式的結果
teenagersLocalDF <- collect(teenagers)

# 把資料集中的 teenagers 印出
print(teenagersLocalDF)

# 停止 SparkContext (最後必定要呼叫)
sparkR.stop()
