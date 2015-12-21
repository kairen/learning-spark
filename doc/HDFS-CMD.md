# HDFS 四個操作命令
#### archive
* 使用方法：hadoop archive -archiveName NAME 『src』 『dest』
* 說明：建立一個hadoop檔案。
* 範例：hadoop archive -archiveName sample.txt /user/file.txt /user/sample.txt

#### distp

* 使用方法： hadoop distp 『scr1』 『scr2』
* 說明：在相同的檔案系統中平行地複製檔案。
* 範例：hadoop distp hdfs://host/user/file1 hdfs://host/user/file2

#### fs
* 使用方法： hadoop fs [COMMAND_OPTIONS]
* 說明：執行一個正常的檔案基本操作指令。
* 範例：hadoop fs -put data.txt /user/wordcount

#### jar
* 使用方法： hadoop jar  <*.jar>  [mainClass]  args....
* 說明：執行一個包含Hadoop程式的 jar檔案。
* 範例：hadoop jar wordcount.jar  wordMain /input/data.txt  /output

# HDFS fs的十八個操作
#### -cat
說明：將路徑指定的檔案輸出到螢幕。
#### -copyFromLocal
說明：複製本機檔案到HDFS上。
#### -copyToLocal
說明：將一個HDFS的檔案複製到本機中。
#### -cp
說明：將檔案複製到指定路徑。可指定多可檔案或目錄。
#### -du
說明：顯示目錄中所有檔案大小，或指定一個檔案顯示大小。
#### -dus
顯示目的檔案大小。
#### -expunge
用於清空資源回收筒。
#### -get
複製檔案到本地檔案系統。
#### -ls
瀏覽本地檔案系統或者HDFS檔案系統。
#### -lsr
透過遞迴查閱檔案內容。
#### -mkdir
建立一個目錄。
#### -mv
移動指定檔案到指定目錄底下。
#### -put
上傳本機檔案到目標HDFS檔案系統。
#### -rm
刪除指定檔案。
#### -rmr
遞迴地刪除指定檔案中的空目錄。
-Setrep
改變一個備份的複製份數。
#### -Test
使用ezd對檔案進行檢查。
#### -text
將檔案輸出為文字格式，執行格式為zip以及Test類別。

# HDFS檔案存取權限
HDFS中存取權限設定傳統有以下四種：
* 唯獨許可權 -r：應用於所有可進入系統使用者，任一使用者讀取或列出檔案內容時，只需要本權限。
* 寫入許可權 -w：下達命令列或API對檔案或檔案目錄進行產生以及刪除等操作時，所需要的權限。
* 讀寫許可權 -rw：同時具備以上兩種，可用於較高權限的使用者。
* 執行許可權 -x：較特殊的檔案設定，HDFS目前沒有可執行擋，所以不需要對此設定。
