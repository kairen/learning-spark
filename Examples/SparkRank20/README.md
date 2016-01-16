## SparkExample Rank20  IMAC - BigData Team - 2015/12/16

###問題描述

從[商品交易紀錄](http://files.imaclouds.com/dataset/HMC-Contest.log) 當中，列出當月銷售最好商品TOP20。

###資料前處理

```
$ wget http://files.imaclouds.com/dataset/HMC-Contest.log
$ cat HMC-Contest.log | grep -o "act=order.*;e" | sed "s/;e//" > RankData
$ hadoop fs -put RankData /input/Rank
```
>將資料做前處理後，可以將不必要的資料排除，由原本的1.5G資料降至幾M，提升資料處理的分析效能

###執行分析

```
spark-submit --class com.imac.test.Main \
--master yarn-cluster Rank.jar \
/input/Rank/RankData \
/spark/RankOutput
```
> 第一行```--class```後面接```Java```的```package name```和```class name```  
> 第二行--master 為使用叢集模式，這邊採用yarn-cluster，後面接```Jar```  
> 第三行和第四行分別為輸入資料和輸出目錄

###輸出結果
>分析成功後，可以使用```hadoop fs -cat /spark/RankOutput/part-00000```指令列出結果，如下:

```
01 0006584093
02 0000143511
03 0007082051
04 0005772981
05 0014252066
06 0006323656
07 0004607050
08 0024239865
09 0003425855
10 0004134266
11 0006993652
12 0004862454
13 0009727250002
14 0006270095
15 0014252055
16 0006993663
17 0009727290016
18 0018504861
19 0000143500
20 0024634260
```