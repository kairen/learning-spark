## SparkGraphXTriangleCount

本範例利用 SparkGraphX 來實作 TriangleCount ，而TriangleCount計算方式則是去計數圖形中，點與點之間組合而成的三角形數量，通常用於社群網路上，可觀察出每個使用者的朋友群狀況




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

### followers示意圖
![followers示意圖](image/graphx.jpg)

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

### TriangleCount後-Edge
```txt
Edge(1,2,1)
Edge(1,4,1)
Edge(3,6,1)
Edge(3,7,1)
Edge(6,7,1)
```

### TriangleCount後-Vertex

```txt
(4,0)
(1,0)
(6,1)
(3,1)
(7,1)
(2,0)
```

### TriangleCount之對應使用者的分析結果
> (使用者名稱，排行分數)

```txt
(ladygaga,0)
(odersky,1)
(matei_zaharia,1)
(justinbieber,0)
(jeresig,1)
(BarackObama,0)
```
