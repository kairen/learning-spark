## SparkGraphXPageRank

本範例利用 SparkGraphX 來實作 PageRank演算法，而PageRank演算法則是透過 `org.apache.spark.graphx.lib`中的 GraphX 函式來取得，並透過 Spark 提供的範例資料來實作使用者與使用者之間的 PageRank。

>PageRank又稱為網頁排名，該演算法是是用來衡量一個圖形中頂點與頂點之間的重要程度，藉由重要程度的大小來進行排名。例如，臉書(FB)朋友與朋友之間的追蹤狀態，可藉由此演算法來計算法每個使用者的重要程度


### 資料1-followers.txt
> 追蹤紀錄 ，例如 `2 1`可表示為2號使用者追蹤1號使用者

```txt
2 1
4 1
1 2
6 3
7 3
7 6
6 7
3 7
```

### 資料2-users.txt
> 使用者編號與使用者名稱

```txt
1,BarackObama,Barack Obama
2,ladygaga,Goddess of Love
3,jeresig,John Resig
4,justinbieber,Justin Bieber
6,matei_zaharia,Matei Zaharia
7,odersky,Martin Odersky
8,anonsys
```

### 輸入資料-Edge
```txt
Edge(1,2,1)
Edge(1,2,1)
Edge(1,4,1)
Edge(3,6,1)
Edge(3,7,1)
Edge(3,7,1)
Edge(6,7,1)
Edge(6,7,1)
```

### 輸入資料-Vertex
```txt
(4,1)
(1,1)
(6,1)
(3,1)
(7,1)
(2,1)
```

### PageRank後-Edge
```txt
Edge(1,2,0.3333333333333333)
Edge(1,2,0.3333333333333333)
Edge(1,4,0.3333333333333333)
Edge(3,6,0.3333333333333333)
Edge(3,7,0.3333333333333333)
Edge(3,7,0.3333333333333333)
Edge(6,7,0.5)
Edge(6,7,0.5)
```

### PageRank後-Vertex

```txt
(4,1.3333E-4)
(1,1.0E-4)
(6,1.3333E-4)
(3,1.0E-4)
(7,2.99976667E-4)
(2,1.6666E-4
```

### PageRank之對應使用者的分析結果
> (使用者名稱，排行分數)

```txt
(odersky,2.99976667E-4')
(ladygaga,1.6666E-4')
(justinbieber,1.3333E-4')
(jeresig,1.0E-4')
(BarackObama,1.0E-4')
(matei_zaharia,1.3333E-4')
```
