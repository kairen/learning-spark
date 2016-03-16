#Streaming KMeans Example

本範例為利用 SparkStreaming 實作一線上KMeans分群演算法的範例


###參數設定

> trainingDir : 訓練目錄
> 
> testDir : 測試目錄
> 
> batchDuration : batch 時間
> 
> numClusters : 分群數量
> 
> numDimensions : 資料維度
 ```
 if (args.length != 5) {
    System.err.println(
          "Usage: StreamingKMeansExample " +
            "<trainingDir> <testDir> <batchDuration> <numClusters> <numDimensions>");
    System.exit(1);
 }
```




### 訓練資料



```
9527,1 2 3
9527,4 5 6
9527,21 22 23
```


### 訓練資料格式處理

>首先針對 "訓練資料" 的程式處理，以 LabelPoint型態輸出，該型態之outpu為 <Double , Vector>
```
JavaDStream<LabeledPoint> trainingData = ssc.textFileStream(args[0]).map(new Function<String, LabeledPoint>() {
    public LabeledPoint call(String line) throws Exception {
         String[] parts = line.split(",");
         String[] features = parts[1].split(" ");
         double[] v = new double[features.length];
         for (int i = 0; i < features.length - 1; i++)
         v[i] = Double.parseDouble(features[i]);
    return new LabeledPoint(Double.parseDouble(parts[0]), Vectors.dense(v));
}
}).cache();
```
    



### 測試資料
```
9527,7 8 9
```

### 測試資料格式處理
```
JavaDStream<LabeledPoint> testData = ssc.textFileStream(args[1]).map(new Function<String, LabeledPoint>() {
  public LabeledPoint call(String line) throws Exception {
           String[] parts = line.split(",");
           String[] features = parts[1].split(" ");
           double[] v = new double[features.length];
           for (int i = 0; i < features.length - 1; i++)
                 v[i] = Double.parseDouble(features[i]);
 return new LabeledPoint(Double.parseDouble(parts[0]), Vectors.dense(v));
 }
});
```


### 產生模型
* setK : 分群數量
* setRandomCenters : 資料維度，例如 ，設定為3
> 例如， 正確{9527, 1 2 3} ， 錯誤{9527,1 2 3 4}


```
StreamingKMeans model = new StreamingKMeans();
model.setK(Integer.parseInt(args[3]));
model.setDecayFactor(1.0);
model.setRandomCenters(Integer.parseInt(args[4]), 0.0,0L);
model.trainOn(trainingData)
```


## 測試結果



### 範例1

### 訓練資料

```
9527,1 2 3
9527,4 5 6
9527,21 22 23
```

### 測試資料

```
9527,7 8 9
```

### 結果
> 分群結果 : 0
```
(9527.0,0)
```

### 範例2

### 訓練資料

```
9527,1 2 3
9527,4 5 6
9527,21 22 23
```

### 測試資料
```
9527,17 18 19
```

### 結果
> 分群結果 : 1
```
(9527.0,1)
```
