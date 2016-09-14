# 載入 SparkR library
library(SparkR)

# 把 SQLContext 初始化
sc <- sparkR.init(appName="SparkR-DataFrame-example")
sqlContext <- sparkRSQL.init(sc)

# 建立一個 data.frame 格式資料
localDF <- data.frame(name=c("John", "Smith", "Sarah"), age=c(19, 23, 18))

#印出 data.frame 內容
print(localDF)

# 轉換本地端 data frame 為 SparkDataFrame
df <- createDataFrame(sqlContext, localDF)
# 印出 df 格式資料
printSchema(df)
# root
#  |-- name: string (nullable = true)
#  |-- age: double (nullable = true)

# 需要把 df 格式資料轉為二維資料表
registerTempTable(df, "people")

# 藉由 sqlContext 可以使用 SQL 語法來做關聯式查詢
adults <- sql(sqlContext, "SELECT name FROM people WHERE age >= 19")

# Call collect to get a local data.frame
# 利用 collect 去取得轉換二維資料表為 data.frame 格式的結果
adultsLocalDF <- collect(adults)

# 把資料集中的 adults 印出
print(adultsLocalDF)

# 停止 SparkContext (最後必定要呼叫)
sparkR.stop()
