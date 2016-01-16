## SparkExample Rate  IMAC - BigData Team - 2015/12/15

###問題描述

從[使用者商品評價](http://files.imaclouds.com/dataset/u.data.csv) 當中，找出條件分別為:
```
1. 使用者編碼為1~10
2. 商品代碼1~10
3. 商品評價在3以上，並由高排低(最高評價5)
```
的商品有哪些。

###資料格式

>使用者代號,商品代號,評價,時間

```
196,242,3,881250949
186,302,3,891717742
```

###資料前處理

```
$ wget http://files.imaclouds.com/dataset/u.data.csv
$ cat u.data.csv | grep -o [0-9].* > RateData
$ hadoop fs -put RateData /input/Rate
```
>將資料做前處理後，把<font color="red">標題部分移除保留資料部分</font>，並存放到HDFS中

###執行分析

```
spark-submit --class com.imac.test.Main \
--master yarn-cluster Rate.jar \
/input/Rate/RateData \
/spark/RateOutput
```
> 第一行```--class```後面接```Java```的```package name```和```class name```  
> 第二行--master 為使用叢集模式，這邊採用yarn-cluster，後面接```Jar```  
> 第三行和第四行分別為```輸入資料```和```輸出目錄```

###輸出結果
>分析成功後，可以使用```hadoop fs -cat /Spark/RateOutput/part-00000```指令列出結果，如下:

```
User 1 評價 Item 6 為 5
User 7 評價 Item 8 為 5
User 9 評價 Item 6 為 5
User 7 評價 Item 7 為 5
User 1 評價 Item 9 為 5
User 1 評價 Item 1 為 5
User 7 評價 Item 4 為 5
User 7 評價 Item 9 為 5
User 10 評價 Item 7 為 4
User 5 評價 Item 1 為 4
User 10 評價 Item 4 為 4
User 7 評價 Item 10 為 4
User 10 評價 Item 1 為 4
........
```