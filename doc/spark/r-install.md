# SparkR

R 語言是一套提供計算和圖形化的運算換境，有項調查表示 R 的使用在資料科學家的應用上僅次於 SQL，所以與資料探勘有著密不可分的關係。
但礙於 R 語言的運算核心是以單執行序環境去運作，所以處理的數據量受限至於單機的記憶體容量。

隨著 Spark 興起成為新一代分佈式系統，搭配 Hadoop 的 HDFS檔案系統，Spark 團隊在 Spark1.4 新增了 SparkR API，讓擅長 R 語言的資料科學家繼續使用 R 去做資料分析，更解決了一些 R 語言的缺失。

首先須先完成 Spark 安裝，參考安裝文件如下:

[Spark Standalone](https://github.com/imac-cloud/spark-tutorial/blob/master/doc/spark/Spark-Standalone-Install.md)

其次更新資源庫，並安裝 R :

```sh
$ sudo apt-get update
$ sudo apt-get install r-base
```

之後就可使用 SparkR
