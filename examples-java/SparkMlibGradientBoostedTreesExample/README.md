#SparkMlib Gradient-Boosted Trees

本範例為利用 SparkMlib 實作一Gradient-Boosted Trees機器學習演算法之廣告點擊預測的範例


###資料格式

> 1-id: 廣告id
> 
> 2-click: 0/1 是否點擊， 0:沒有 1:點擊
> 
> 3-hour: 時間格式 YYMMDDHH
> 
> 4-C1 
> 
> 5-banner_pos
> 
> 6-site_id
> 
> 7-site_domain
> 
> 8-site_category
> 
> 9-app_id
> 10-app_domain
> 
> 11-app_category
> 
> 12-device_id
> 
> 13-device_ip
> 
> 14-device_model
> 
> 15-device_type
> 
> 16-device_conn_type
> 
> 17~24—C14-C21 
 ```
 1000009418151094273,0,14102100,1005,0,1fbe01fe,f3845767,28905ebd,ecad2386,7801e8d9,07d7df22,a99f214a,ddd2926e,44956a24,1,2,15706,320,50,1722,0,35,-1,79
 ```


###切割訓練資料和測試資料
 ```
JavaRDD<String>[] slice = rawRDD.randomSplit(new double[] { 0.8, 0.2 });

JavaRDD<String> train_rdd = slice[0];
JavaRDD<String> test_rdd = slice[1];

```




###訓練資料

將訓練資料進行資料前處理，把是否點擊、分類特徵和數值特徵分開
>   catkey -> 1000009418151094273::0 //  {廣告id/是否點擊}
>   
>   第6列~第15列為分類特徵
>   
>   第16列~第24列為數值特徵
>   



```
JavaRDD<Tuple3<String, List<String>, List<String>>> featrueRDD = train_rdd.map(new Function<String, Tuple3<String, List<String>, List<String>>>() {
        public Tuple3<String, List<String>, List<String>> call(String arg0) throws Exception {
            String[] token = arg0.split(",");
            String catkey = token[0] + "::" + token[1];
            List<String> catfeatures = new ArrayList<String>();
            for (int i = 5; i <= 14; i++) {
                catfeatures.add(token[i]);
            }

            List<String> numericalfeatures = new ArrayList<String>();
            for (int i = 15; i < token.length; i++) {
                numericalfeatures.add(token[i]);
            }

            return new Tuple3<String, List<String>, List<String>>(catkey, catfeatures, numericalfeatures);
        }
    });
```

將分類特徵擷取出來，準備做特正向量化 (原因是分類特徵為文字部分，需先將其向量化)
> parseCatFeatures 是一個 method 
> >input : (1fbe01fe,f3845767,28905ebd,ecad2386,7801e8d9)
> >
> >output : ((0:1fbe01fe),(1:f3845767),(2:28905ebd),(3:ecad2386),(4:7801e8d9))


```
JavaRDD<ArrayList<Tuple2<Integer, String>>> train_cat_rdd = featrueRDD
    .map(new Function<Tuple3<String, List<String>, List<String>>, ArrayList<Tuple2<Integer, String>>>() {
              public ArrayList<Tuple2<Integer, String>> call(Tuple3<String, List<String>, List<String>> arg0) throws Exception {
                  return parseCatFeatures(arg0._2());
              }
});
```
 
將分類特徵轉成向量化，並存成Map型態做儲存
>轉成向量化，主要依賴 .zipWithIndex()，其可將RDD中的數值依序給予一個數值ID
>> input :  RDD<"A","B","C">
>> 
>> output : Array<(A,0),(B,1),(C,2)>
```
final Map<Tuple2<Integer, String>, Long> oheMap = train_cat_rdd.flatMap(new FlatMapFunction<ArrayList<Tuple2<Integer, String>>, Tuple2<Integer, String>>() {
    public Iterable<Tuple2<Integer, String>> call(ArrayList<Tuple2<Integer, String>> arg0) throws Exception {
        return arg0;
    }
}).distinct().zipWithIndex().collectAsMap();
```

這部分針對是否點擊、分類特徵和數值特徵，分別將塞入 LabeledPoint 型態中
> LabeledPoint< Double,Vector > :  <是否點擊，{分類特徵向量+數值特徵向量}>
> 




```
JavaRDD<LabeledPoint> ohe_train_rdd = featrueRDD.map(new Function<Tuple3<String, List<String>,List<String>>, LabeledPoint>() {
public LabeledPoint call(Tuple3<String, List<String>,List<String>> arg0) throws Exception {
    ArrayList<Tuple2<Integer, String>> cat_features_indexed = parseCatFeatures(arg0._2());
    ArrayList<Double> cat_feature_ohe = new ArrayList<>();
    for (Tuple2<Integer, String> v : cat_features_indexed) {
        if (oheMap.containsKey(v)) {
            double b = (double) oheMap.get(v);
            cat_feature_ohe.add(b);
        } else {
            cat_feature_ohe.add(0.0);
        }
    }

    Object[] aa = cat_feature_ohe.toArray();

    double[] dd = new double[aa.length];
    for (int i = 0; i < aa.length; i++) {
        dd[i] = (double) aa[i];
    }

    ArrayList<String> numerical_features_dbl = new ArrayList<>();
    for(String v : arg0._3()){
        if(Integer.parseInt(v)<0){
            numerical_features_dbl.add("0");
        }else{
            numerical_features_dbl.add(v);
        }
    }
    Object[] num_obj = numerical_features_dbl.toArray();
    double[] num_double = new double[num_obj.length];
    for (int i = 0; i < num_double.length; i++) {
        num_obj[i] = (double) num_double[i];
    }

    double [] features=  new double [num_double.length];
    for (int i = 0; i < num_double.length; i++) {
        features[i] = dd[i]+num_double[i];
    }
    return new LabeledPoint(Double.parseDouble(arg0._1().split("::")[1]), Vectors.dense(features));
}
});
```

將 ```RDD<LabeledPoint> ```放入 ```GradientBoostedTreesModel``` 進行 training
```
BoostingStrategy boostingStrategy = BoostingStrategy.defaultParams("Classification");
boostingStrategy.setNumIterations(10); 
boostingStrategy.getTreeStrategy().setNumClasses(2);
boostingStrategy.getTreeStrategy().setMaxDepth(10);

final GradientBoostedTreesModel model = GradientBoostedTrees.train(ohe_train_rdd, boostingStrategy);
```

模型的儲存/讀取
> /GradientBoostedTreesModel  :  HDFS的路徑
```
model.save(sc.sc(), "/GradientBoostedTreesModel");
GradientBoostedTreesModel model = GradientBoostedTreesModel.load(sc.sc(), "/GradientBoostedTreesModel");
```


###測試資料

與 train data 做相同的事情，將是否點擊、分類特徵和數值特徵塞入 LabeledPoint 中，只是資料換成測試資料
```
JavaRDD<LabeledPoint> testData = test_raw_data.map(new Function<Tuple3<String,List<String>, List<String>>, LabeledPoint>() {
  public LabeledPoint call(Tuple3<String,List<String>, List<String>> arg0) throws Exception {
      ArrayList<Tuple2<Integer, String>> cat_features_indexed = parseCatFeatures(arg0._2());
      ArrayList<Double> cat_feature_ohe = new ArrayList<>();
      for (Tuple2<Integer, String> v : cat_features_indexed) {
          if (oheMap.containsKey(v)) {
              double b = (double) oheMap.get(v);
              cat_feature_ohe.add(b);
          } else {
              cat_feature_ohe.add(0.0);
          }
      }

      Object[] aa = cat_feature_ohe.toArray();

      double[] dd = new double[aa.length];
      for (int i = 0; i < aa.length; i++) {
          dd[i] = (double) aa[i];
      }

      ArrayList<String> numerical_features_dbl = new ArrayList<>();
      for(String v : arg0._3()){
          if(Integer.parseInt(v)<0){
              numerical_features_dbl.add("0");
          }else{
              numerical_features_dbl.add(v);
          }
      }
      Object[] num_obj = numerical_features_dbl.toArray();
      double[] num_double = new double[num_obj.length];
      for (int i = 0; i < num_double.length; i++) {
          num_obj[i] = (double) num_double[i];
      }

      double [] features=  new double [num_double.length];
      for (int i = 0; i < num_double.length; i++) {
          features[i] = dd[i]+num_double[i];
      }
      return new LabeledPoint(Double.parseDouble(arg0._1().split("::")[1]), Vectors.dense(features));
  }
});
```

利用 training 出來的 model 針對 testing data 的向量特徵去預測是否點擊
> outpu : Tuple2< Double, Double> :  <預測是否點擊結果 ，真正是否點擊的結果>
```
JavaPairRDD<Double, Double> predictionAndLabel = testData.mapToPair(new PairFunction<LabeledPoint, Double, Double>() {
    public Tuple2<Double, Double> call(LabeledPoint p) {
        return new Tuple2<Double, Double>(model.predict(p.features()), p.label());
    }
});
```

錯誤率計算
```
Double testErr = 1.0 * predictionAndLabel.filter(new Function<Tuple2<Double, Double>, Boolean>() {
    public Boolean call(Tuple2<Double, Double> pl) {
        return !pl._1().equals(pl._2());
    }
}).count() / testData.count();
```


結果
```
Test Error: 0.34615384615384615
Learned classification GBT model:
TreeEnsembleModel classifier with 10 trees

Tree 0:
If (feature 5 <= 119.0)
 If (feature 0 <= 15.0)
  Predict: 1.0
 Else (feature 0 > 15.0)
  If (feature 7 <= 181.0)
   If (feature 7 <= 172.0)
    If (feature 7 <= 75.0)
     If (feature 7 <= 71.0)
      If (feature 8 <= 200.0)
       If (feature 8 <= 117.0)
        Predict: -1.0
       Else (feature 8 > 117.0)
        If (feature 0 <= 162.0)
         Predict: -1.0
        Else (feature 0 > 162.0)
         If (feature 0 <= 183.0)
          Predict: 1.0
         Else (feature 0 > 183.0)
          Predict: -1.0
      Else (feature 8 > 200.0)
       Predict: 1.0
     Else (feature 7 > 71.0)
      Predict: 1.0
    Else (feature 7 > 75.0)
     If (feature 1 <= 30.0)
      Predict: 1.0
     Else (feature 1 > 30.0)
      If (feature 7 <= 161.0)
       If (feature 7 <= 116.0)
        If (feature 7 <= 113.0)
         Predict: -1.0
        Else (feature 7 > 113.0)
.....
```