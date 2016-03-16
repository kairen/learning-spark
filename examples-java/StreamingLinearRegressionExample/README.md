#Streaming Linear Regression

本範例為利用 SparkStreaming 實作一線上Linear Regression線性回歸演算法的範例


###參數設定

> trainingDir : 訓練目錄
> 
> testDir : 測試目錄
> 
```
if (args.length != 2) {
System.err.println("Usage: StreamingLinearRegressionExample <trainingDir> <testDir>");
System.exit(1);
}
```




### 訓練資料



```
9527,1 2 3
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
9527,100 200 300
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
*  numFeatures 是單筆資料 Vector數量，例如 ，設定為3
> 例如， 正確{9527, 1 2 3} ， 錯誤{9527,1 2 3 4}


```

int numFeatures = 3;
StreamingLinearRegressionWithSGD model = new StreamingLinearRegressionWithSGD()
                  .setInitialWeights(Vectors.zeros(numFeatures));
```

### 計算 MSE (均方誤差)
>均方誤差(Mean Square Error, MSE)是衡量“平均誤差”的一種較方便的方法,可以評價數據的變化程度。均方根誤差是均方誤差的算術平方根。

```
predic_result.foreach(new Function<JavaPairRDD<Double,Double>, Void>() {
public Void call(JavaPairRDD<Double, Double> arg0) throws Exception {
    if(!arg0.isEmpty()){
        Double MSE = new JavaDoubleRDD(arg0.map(new Function<Tuple2<Double,Double>, Object>() {
            public Object call(Tuple2<Double, Double> pair)
                    throws Exception {
                return Math.pow(pair._1() - pair._2(), 2.0);
            }
        }).rdd()).mean();
        System.out.println("training Mean Squared Error = " + MSE);
    }
    return null;
}
});
```




## 測試結果



### 範例1

### 訓練資料

```
9527,1 2 3
```

### 測試資料

```
9527,100 200 300
```

### 結果
> 945033.2506427156 : 預測數據
> 
> 9527.0 : 原來數據
```
(9527.0,945033.2506427156)
```

### 範例2

### 訓練資料

```
9527,1 2 3
```

### 測試資料
```
9527,66 78 89
```

### 結果
```
(9527.0,440385.49479950545)
```
