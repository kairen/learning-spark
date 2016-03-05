package com.spark;

import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.PairFunction;
import scala.Tuple2;


/**
 * Created by kairenbai on 2015/3/19.
 */
public class CompareWordFunction implements PairFunction<String, String, String> {

    private static JavaRDD<String> dictRDD;
    private static int countSum = 0;
    private static String appendStr = "";

    public  CompareWordFunction(JavaRDD<String> dict) {
        this.dictRDD =  dict;
    }

    @Override
    public Tuple2<String, String> call(String line) throws Exception {

        String []lines = line.split(",");
        String []keyWords = {
                "台北", "桃園", "基隆", "宜蘭", "花蓮", "台東", "新竹",
                "屏東", "高雄", "台南", "雲林", "彰化", "台中", "苗栗"
        };

//        Iterable<String>  keyWords = dictRDD.collect();
        countSum = 0;
        appendStr = "";

        for (String word : keyWords) {
            int count = numberOfString(lines[3] + lines[4] + lines[5], word);
            appendStr += word + ":" + count + ",";
            countSum += count;
        }
        appendStr += "wordSum:" + countSum;
        return new Tuple2<String, String>(lines[0], appendStr);
    }

    /**
     * WordCount of String
     *
     * @param  str searched wordcount
     * @return An integer containing the wordcount value
     */
    public int numberOfString(String str, String word) {
        if(str.endsWith(word)) {
            return str.split(word).length;
        } else {
            return str.split(word).length - 1;
        }
    }
}
