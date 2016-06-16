# SparkMlib Naive Bayes

本範例為利用 SparkMlib 實作一Naive Bayes機器學習演算法之中文文章分類的範例，分類過程分別包含了文字分詞、TF-IDF、模型訓練和模型預測


[範例資料](http://files.imaclouds.com/dataset/sougou-train.tar.gz)

### 資料種類與格式

> C000007 汽车

> C000008 財經

> C000010 IT

> C000013 健康

> C000014 體育

> C000016 旅遊

> C000020 教育

> C000022 工作招聘

> C000023 文化

> C000024 軍事

```txt
0,昨天下午 3点 机场 五元 桥底下 一辆 973路 公交车 桥洞 发生 撞倒 路边 一根 又将 一辆 三轮车 公交 车队 工作人员 介绍 事故 下雨 目击者 973路 公车 由东向西 拐过 五元 桥洞 逆行 车道 滑去 撞上 路边 一根 一辆 三轮车 顶到 一辆 909路 公交车 停下 三轮 车主 倒在 身上 流出 下午 4点 车牌 g31316 973路 公交车 停在 由西向东 道上 车前 挡风玻璃 破裂 左侧 一根 10米 路灯 连根拔起 车头 左侧 一辆 装有 马达 三轮车 变形 车上 留有 血迹 公交车 尾部 一条 5米 刹车 下午 5点 酒仙桥  医院 受伤 三轮车 车主 接受 治疗 医生 伤者 右腿 骨折 生命危险 973路 车队 一名 工作人员 下雨 路面 司机 拐弯 发生 车速 三十 事故 发生后 上将 伤者 送到 医院 救治 付了 医疗 费用 受伤 住院治疗
0,nbsp 1990年 学会 汽车 拿下 驾驶证 第一 个月 最想 两件事 开车 人和 长途 快下班 的时候 拿着 钥匙 驾照 开车 送你 单位 同事 都让 开车 上路 就有 一种 兴奋 冯小刚 奔驰车 性能 特别 但他 超速 开车 速度 行车 情况 及时处理 没把握 开车 前车 距离 至关重要 吃过 那天 北京
0,月初 时代 领航 1.900米 宽体 车身 动力 转向 七大 武器 强势 入市 销售 全新 1.900米 宽体 车身 时代 领航 采用 全新 1.9米 车身 前排 乘座 不觉得 动力 转向系统 引领 经济型 市场 配置 升级 时代 领航 配了 动力 转向 驾驶 两根 手指 即可 轻松 方向盘 这车 长途 路况 不好 路面 准保 不累 全新 五十铃 底盘 配置 全面提高 车辆 安全性 承载 能力 时代 领航 搭载 cy4100q 发动机 动力 强劲 配装 五十铃 变速箱 性能 稳定 扭矩 承载 能力 多载 1吨 单排 货箱 长度 4.25米 更适合 装载 加长 货物 时代 领航 首次 装了 沙漠 滤器 发动机 双层 过滤 延长 发动机 滤器 使用寿命 更能 用户 车辆 成本 进一步 降低 时代 领航 标配 排气 制动 装置 以使 车辆 双重 制动 提高 行车 安全性 长了 制动器 使用寿命 市场 竞争 进一步 加剧 在所难免 领航 企业 不断扩大 优势 才有 常胜将军
0,听证 会上 反对 涨价 声音 听证 方案 不合理 之处 听证 代表 出了 出租车 公司 利润率 质疑 应由 出租车 公司 司机 乘客 三方 承担 燃油 涨价 成本 而非 司机 乘客 两方 承担 反对 声音 运管局 提供 不实 数据 未能 出席 听证会 代表 托人 来了 书面 批评 运输 管理局 提供 申请 方案 模糊 概念 不实 数据 听证 代表 进行了 误导 这是 错误 提出 出租车 行业 就可以 个体经营 北京市 现有 个体 出租司机 几千元 管理 成本 依法 经营 税后 入会 颇丰 相比之下 出租车 公司 一直在 苦叫 政府 行政 手段 保证 企业 暴利 政府 行政 特许 垄断 方式 早该 结束 陈建民 担心 提价 黑车 猖獗 注意到 今天在 场上 和我
0,搜狐汽车 全新 报价 系统 上线 抢先 体验 gt gt 伊兰特 详细 报价 nbsp 凯越 详细 报价 nbsp 福美来 详细 报价 nbsp 详细 报价 nbsp 力帆520 详细 报价 nbsp 一辆 我爱你 为名 新型 经济型 家庭轿车 竞争 最为

 ```


### 將輸入資料轉換成 JavaRDD<Row>型態
>  RowFactory.create() 函式中，以逗號區分來代表欄位順序，例如，`tokens[0],tokens[1]`則分別代表欄位一和欄位二

 ```java
JavaRDD<Row> rowRDD = srcRDD.map(new Function<String, Row>() {
	public Row call(String arg0) throws Exception {
		String [] tokens = arg0.split(",");
		return RowFactory.create(tokens[0],tokens[1]);
	}
});

```

### 切割資料類型
> 70%訓練資料，30%測試資料

 ```java

JavaRDD<Row>[] splitRDD = rowRDD.randomSplit(new double [] {0.7,0.3});

JavaRDD<Row> trainRDD = splitRDD[0].cache();
JavaRDD<Row> testRDD = splitRDD[1].cache();

```

### 將 JavaRDD<Row>型態 的資料轉成 DataFrame型態
> createStructType() 方法中， `category` 和 `text` 則分別代表欄位名稱，可自行定義

 ```java

DataFrame trainDF = sqlContext.createDataFrame(trainRDD, createStructType());

 ```

 ```java
private static StructType createStructType() {
    List<StructField> fields = new ArrayList<>();
    fields.add(DataTypes.createStructField("category", DataTypes.StringType, true));
    fields.add(DataTypes.createStructField("text", DataTypes.StringType, true));
    StructType schema = DataTypes.createStructType(fields);
    return schema;
}

```


### 文字分詞
> 針對輸入資料進行文字分詞，將欄位`text`的文章內容進行文字分詞並輸出結果到欄位`words`



```java

Tokenizer tokenizer = new Tokenizer().setInputCol("text").setOutputCol("words");
DataFrame wordsData = tokenizer.transform(trainDF);
wordsData.printSchema();
System.out.println(wordsData.select("category","text","words").take(1)[0]);
```
wordsData schema

```sh
root
 |-- category: string (nullable = true)
 |-- text: string (nullable = true)
 |-- words: array (nullable = true)
 |    |-- element: string (containsNull = true)
```

wordsData 第一筆資料內容

```sh
[0,polo1.4 自动 舒适 标准价 121000元 现价 111600元 降幅 9400元 预计 再降 400元 桑塔纳 3000 手动 标准型 标准价 118000元 现价 107000元 降幅 11000元 预计 再降 1000元 爱丽舍 报价 图片 自动 天窗 nbsp 标准价 122800元 现价 109600元
降幅 13200元 预计 再降 400元 凯越 1.6 手动 舒适 标准价 117800元 现价 107600元 降幅 10200元 预计 再降 400元 标致 3072.0 手动 舒适 307qianlongqiche.jpg 标准价 175800元 现价 163500元 降幅 12300元 预计 再降 300元 nf2.0 自动
豪华 标准价 195800元 现价 185300元 降幅 10500元 预计 再降 300元 蒙迪欧 2.0 经典 标准价 179800元 现价 168800元 降幅 11000元 预计 再降 500元 陆尊 3.0 豪华 标准价 318000元 现价 302200元 降幅 15800元 预计 再降 800元 陆尊 3.0
旗舰 标准价 358000元 现 339500元 降幅 18500元 预计 再降 500元 ,WrappedArray(polo1.4, 自动, 舒适, 标准价, 121000元, 现价, 111600元, 降幅, 9400元, 预计, 再降, 400元, 桑塔纳, 3000, 手动, 标准型, 标准价, 118000元, 现价, 107000元, 降幅, 11000元, 预计, 再降, 1000元, 爱丽舍, 报价, 图片, 自动, 天窗, nbsp, 标准价, 122800元, 现价, 109600元, 降幅, 13200元, 预计, 再降, 400元, 凯越, 1.6, 手动, 舒适, 标准价, 117800元, 现价, 107600元, 降幅,
10200元, 预计, 再降, 400元, 标致, 3072.0, 手动, 舒适, 307qianlongqiche.jpg, 标准价, 175800元, 现价, 163500元, 降幅, 12300元, 预计, 再降, 300元, nf2.0, 自动, 豪华, 标准价, 195800元, 现价, 185300元, 降幅, 10500元,
预计, 再降, 300元, 蒙迪欧, 2.0, 经典, 标准价, 179800元, 现价, 168800元, 降幅, 11000元, 预计, 再降, 500元, 陆尊, 3.0, 豪华, 标准价, 318000元, 现价, 302200元, 降幅, 15800元, 预计, 再降, 800元, 陆尊, 3.0, 旗舰, 标准价,
358000元, 现价, 339500元, 降幅, 18500元, 预计, 再降, 500元)]

```

### 字頻計算
> 針對 wordsData 進行字頻計算，將欄位`words`的內容進行字頻計算並輸出結果到欄位`rawFeatures`

> setNumFeatures(500000) 表示為總共特徵數量，數量越高記憶體需求越高
> 例如 ,`[0,WrappedArray(polo1.40,(500000,[11727])]` ， 則表示為 字詞polo1.40 ，在500000中的11727代表該字詞，因此可解釋為當特徵越高，字詞種類被區分更細，而特徵數量越低，字詞種類則越少，表示不同詞意的字詞會被歸到同一編號上





```java

HashingTF hashingTF = new HashingTF().setNumFeatures(500000).setInputCol("words").setOutputCol("rawFeatures");
DataFrame featurizedData = hashingTF.transform(wordsData);
featurizedData.printSchema();
System.out.println(featurizedData.select("category","words","rawFeatures").take(1)[0]);
```

featurizedData schema

```sh
root
 |-- category: string (nullable = true)
 |-- text: string (nullable = true)
 |-- words: array (nullable = true)
 |    |-- element: string (containsNull = true)
 |-- rawFeatures: vector (nullable = true)
```

featurizedData 第一筆資料內容

```sh
[0,WrappedArray(polo1.4, 自动, 舒适, 标准价, 121000元, 现价, 111600元, 降幅, 9400元, 预计, 再降, 400元, 桑塔纳, 3000, 手动, 标准型, 标准价, 118000元, 现价, 107000元,
降幅, 11000元, 预计, 再降, 1000元, 爱丽舍, 报价, 图片, 自动, 天, nbsp, 标准价, 122800元, 现价, 109600元, 降幅, 13200元, 预计, 再降, 400元, 凯越, 1.6, 手动, 舒适, 标准价,
117800元, 现价, 107600元, 降幅, 10200元, 预计, 再降, 400元, 标致, 3072.0, 手动, 舒适, 307qianlongqiche.jpg, 标准价, 175800元, 现价, 163500元, 降幅, 12300元, 预计, 再降,
300元, nf2.0, 自动, 豪华, 标准价, 195800元, 现价, 185300元, 降幅, 10500元, 预计, 再降, 300元, 蒙迪欧, 2.0, 经典, 标准价, 179800元, 现价, 168800元, 降幅, 11000元, 预计, 再降,
500元, 陆尊, 3.0, 豪华, 标准价, 318000元, 现价, 302200元, 降幅, 15800元, 预计, 再降, 800元, 陆尊, 3.0, 旗舰, 标准价, 358000元, 现价, 339500元, 降幅, 18500元, 预计, 再降, 500元
),(500000,[11727,20830,24487,27209,27392,48569,49524,50485,51371,52158,67005,69104,79315,85048,87760,91437,92209,103738,108041,117551,128565,135652,147342,175516,177445,
185664,186459,192917,215376,215875,216132,216920,219625,228476,236715,238958,246109,247105,250916,258248,261560,263756,265470,290678,301213,303058,304749,306942,326746,
341529,358829,366178,374865,377724,396912,422215,435454,438311,480742,485939,498699],[1.0,1.0,1.0,1.0,1.0,1.0,1.0,2.0,1.0,3.0,1.0,3.0,2.0,1.0,2.0,1.0,1.0,1.0,1.0,3.0,1.0,
2.0,2.0,1.0,1.0,9.0,1.0,1.0,1.0,1.0,2.0,9.0,1.0,1.0,1.0,1.0,9.0,1.0,1.0,1.0,9.0,1.0,1.0,1.0,3.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,9.0,1.0,1.0,1.0])]
```


### TF-IDF
> 針對 featurizedData 計算出 TF-IDF，將欄位`rawFeatures`的內容進行 TF-IDF 計算並輸出結果到欄位`features`


```java
IDF idf = new IDF().setInputCol("rawFeatures").setOutputCol("features");
IDFModel idfModel = idf.fit(featurizedData);
DataFrame rescaledData = idfModel.transform(featurizedData);
rescaledData.printSchema();
System.out.println(rescaledData.select("category","features").take(1)[0]);
```

rescaledData schema

```sh
root                                                                            
 |-- category: string (nullable = true)
 |-- text: string (nullable = true)
 |-- words: array (nullable = true)
 |    |-- element: string (containsNull = true)
 |-- rawFeatures: vector (nullable = true)
 |-- features: vector (nullable = true)
```

rescaledData 第一筆資料內容

```sh
[0,(500000,[11727,20830,24487,27209,27392,48569,49524,50485,51371,52158,67005,69104,79315,85048,87760,91437,92209,103738,108041,117551,128565,135652,147342,175516,177445,185664,186459,192917,
215376,215875,216132,216920,219625,228476,236715,238958,246109,247105,250916,258248,261560,263756,265470,290678,301213,303058,304749,306942,326746,341529,358829,366178,374865,377724,396912,422215,
435454,438311,480742,485939,498699],[7.928406026180535,6.829793737512425,7.928406026180535,3.2509151786128174,7.928406026180535,3.7463558835393287,3.201018207468194,8.956836960697895,7.928406026180535,
7.337057809904156,3.7773661202818887,7.312212947408991,13.084223330121288,7.52294091807237,9.674727145644438,7.928406026180535,7.928406026180535,7.01211529430638,7.928406026180535,17.03134268272212,
5.848964484500699,4.659968134364321,9.265138320352412,7.928406026180535,7.928406026180535,48.99149438753282,3.0343045483402307,7.928406026180535,7.52294091807237,7.52294091807237,12.113207698557886,
30.18325542909437,2.627591779433911,7.928406026180535,5.254257376754007,3.491654491817407,19.611117362450532,3.8175321620072236,4.167205910486973,7.2352588456205895,67.70646826265133,4.1442163922622735,
7.928406026180535,3.509565418383937,8.012731962458261,2.3486762001943124,7.928406026180535,7.928406026180535,7.928406026180535,4.1442163922622735,3.87662107837723,7.928406026180535,1.9482552389728263,
7.928406026180535,3.4230561754746542,7.52294091807237,7.928406026180535,52.64068036050629,7.52294091807237,7.928406026180535,7.928406026180535])]

```

### 訓練資料-特徵擷取
> 訓練資料的部分要將資料轉換成 JavaRDD<LabeledPoint> 的資料型態，LabeledPoint 分別由 Double型態 和 Vector型態所組成， Double型態則為分類標籤，Vector型態則為分類的特徵向量

> 特徵向量的擷取則是利用先前所計算的 文字分詞、TF-IDF和特徵總數量來組合而成，例如，`[0,(3,[2],[7.928])]`，總特徵為3;編號為2;TF-IDF為7.928 ，而其特徵向量需表示為 `Array(0,[0,0,7.928])`


```java
JavaRDD<LabeledPoint> trainDataRdd = rescaledData.select("category","features").toJavaRDD().map(new Function<Row, LabeledPoint>() {
	public LabeledPoint call(Row arg0) throws Exception {
		String outputString =arg0.get(1).toString();
		String total = outputString.substring(1, outputString.indexOf(","));
		String key = outputString.substring(outputString.indexOf("[")+1, outputString.indexOf("]"));
		String value = outputString.substring(outputString.lastIndexOf("[")+1, outputString.lastIndexOf("]"));

		HashMap<Integer, Double> masHashMap = new HashMap<>();

		String [] key_token = key.split(",");
		String [] value_token = value.split(",");

		for(int i=0; i<key_token.length; i++){
			masHashMap.put(Integer.parseInt(key_token[i]), Double.parseDouble(value_token[i]));
		}

		double [] vectors = new double [Integer.parseInt(total)];
		for(int i=0 ;i<vectors.length;i++){
			if(isContain(key_token,i)){
			  vectors[i] = masHashMap.get(i);
			}else{
			  vectors[i] =0.0;
			}
		}
		return new LabeledPoint(Double.parseDouble(arg0.get(0).toString()),Vectors.dense(vectors));
	}
});
```

### 模型訓練


```java
final NaiveBayesModel model = NaiveBayes.train(trainDataRdd.rdd(), 1.0);
```

### 測試資料-特徵擷取
> 如上述的步驟，只將資料換成訓練資料


```java
DataFrame testDF = sqlContext.createDataFrame(testRDD,createStructType());
DataFrame testwordsData = tokenizer.transform(testDF);
DataFrame testfeaturizedData = hashingTF.transform(testwordsData);
DataFrame testrescaledData = idfModel.transform(testfeaturizedData);
JavaRDD<LabeledPoint> testDataRdd  =testrescaledData.select("category","features").toJavaRDD().map(new Function<Row, LabeledPoint>() {
    public LabeledPoint call(Row arg0) throws Exception {
        String outputString =arg0.get(1).toString();
        String total = outputString.substring(1, outputString.indexOf(","));
        String key = outputString.substring(outputString.indexOf("[")+1, outputString.indexOf("]"));
        String value = outputString.substring(outputString.lastIndexOf("[")+1, outputString.lastIndexOf("]"));

        HashMap<Integer, Double> masHashMap = new HashMap<>();

        String [] key_token = key.split(",");
        String [] value_token = value.split(",");

        for(int i=0; i<key_token.length; i++){
        masHashMap.put(Integer.parseInt(key_token[i]), Double.parseDouble(value_token[i]));
        }

        double [] vectors = new double [Integer.parseInt(total)];
        for(int i=0 ;i<vectors.length;i++){
        if(isContain(key_token,i)){
          vectors[i] = masHashMap.get(i);
        }else{
          vectors[i] =0.0;
        }
    }
    return new LabeledPoint(Double.parseDouble(arg0.get(0).toString()),Vectors.dense(vectors));
  }
});
```



### 驗證模型
> 計算預測精準度

```java
JavaRDD<Tuple2<Double, Double>> testpredictionAndLabel = testDataRdd.map(new Function<LabeledPoint, Tuple2<Double,Double>>() {
    public Tuple2<Double, Double> call(LabeledPoint arg0) throws Exception {
        return new Tuple2<Double, Double>(model.predict(arg0.features()), arg0.label());
    }
});

double testaccuracy = 1.0 * testpredictionAndLabel.filter(new Function<Tuple2<Double,Double>, Boolean>() {
    public Boolean call(Tuple2<Double, Double> arg0) throws Exception {
        return ((arg0._1-arg0._2) == 0.0)?true:false;
    }
}).count()/testDataRdd.count();

System.out.println("Accuracy  : "+testaccuracy);
```
