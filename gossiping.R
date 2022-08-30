#下載套件
packages = c("tidyverse", "rvest", "stringr", "jiebaR", "tmcn","tm","tidytext","wordcloud2")
existing = as.character(installed.packages()[,1])
for(pkg in packages[!(packages %in% existing)]) install.packages(pkg)
#匯入
library(tidyverse) #內含資料處理套件(dplyr)和繪圖套件(ggplot2)等
library(rvest) #網⾴解析處理套件
library(stringr) #字串處理套件
library(jiebaR) #⽂字斷詞
library(tmcn) #⽂字字庫
library(httr) #為了要設定cookie通過八卦版的18歲認證
library(tm)
library(tidytext)
library(wordcloud2)
#https://transbiz.com.tw/regex-regular-expression-ga-%E6%AD%A3%E8%A6%8F%E8%A1%A8%E7%A4%BA%E5%BC%8F/ ->正規表示式
#https://yaojenkuo.io/r-crawler/chapter08.slides.html#/4 ->如何通過18歲限制
Gossiping_url <- "https://www.ptt.cc/bbs/Gossiping/index.html"

page.latest <- Gossiping_url %>%
    GET(set_cookies(over18 = 1)) %>%
    read_html() %>% 
    html_nodes("a") %>% #抓取a的資料
    html_attr("href") %>% #a底下屬性是href的物件
    str_subset("index[0-9]{2,}\\.html") %>% #篩選符合 index 後⾯接⼀串數字的連結 ，0~9要出現兩個以上
    str_extract("[0-9]+") %>% #擷取連結內數字的部分
    as.numeric()  #轉換成數字
page.latest
#透過以上步驟即可得到最新⾴⾯的號碼數 page.latest

all_url_page = paste0("https://www.ptt.cc/bbs/Gossiping/index",
                      (page.latest-2):page.latest,'.html') #抓幾頁
all_url_data = c();recom=c(); title=c(); date=c() #用來儲存每一頁的url、推文數、標題及日期


for(i in 1:length(all_url_page)){
    get18 = all_url_page[i] %>% GET(set_cookies(over18 = 1))
    all_url_data = c(all_url_data, get18 %>% read_html(all_url_page[i]) %>% 
                         html_nodes(css = ".title a") %>% html_attr('href'))
    recom = c(recom,get18 %>% read_html(all_url_page[i]) %>% html_nodes(css = ".nrec") %>%
                  html_text())
    title = c(title, get18 %>% read_html(all_url_page[i]) %>% html_nodes(css = ".title") %>% 
                  html_text())
    date = c(date, get18 %>% read_html(all_url_page[i]) %>% html_nodes(css = ".date") %>%
                 html_text())
    removeSite = grep("\\刪除)",title)
    if(length(removeSite)>0){
        date <- date[-removeSite]
        title <- title[-removeSite]
        recom = recom[-removeSite]
    }
    # sleep(0.1)
}

#read_html 函數先將整個網頁的原始 HTML 程式碼抓下來
#html_text 是將HTML 程式碼中的文字資料取出來

title=title %>% stringr::str_trim() #去除空白
# 合併推⽂資料
my_data = data.frame(recom,date,title)
all_url_data = paste0('https://www.ptt.cc',all_url_data)

#抓文章內容、推文數
content=c()

for(i in 1:length(all_url_data)){
    get18 = all_url_data[i] %>% GET(set_cookies(over18 = 1))
    tryCatch({content = c(content,get18 %>% read_html(all_url_data[i]) %>% 
                              html_nodes(css = "#main-content") %>% html_text())
              # pushcontent = c(pushcontent,get18 %>% read_html(all_url_data[i]) %>% 
              #                 html_nodes(css = ".push-content") %>% html_text())
    cat(i,"\n")},error=function(err){
        message("Original error message:",i)
        message(paste0(err,"\n"))
        return(i=i+1)}
    )}

my_data = cbind(my_data,data.frame(content=content))

#清理文章
content_ques = my_data$content %>% 
    gsub(pattern = "作者.+:[0-9]{2}\\s[0-9]{4}?",., replacement = "") %>% # 去頭 
    gsub(pattern = "(\n--\n※).+",., replacement = "")  # 去尾


content_ques = content_ques %>%
    gsub(pattern = "(http|https)://[a-zA-Z0-9./?=_-]+",., replacement = "") %>% #去除網頁
    gsub(pattern = "引述《[a-zA-Z0-9./_()].+》之銘言",., replacement = "") %>% #去除引述
    gsub(pattern = "Sent from [a-zA-Z0-9 -./_()]+",., replacement = "") %>% #去除Sent from
    gsub(pattern = "<U[a-zA-Z0-9 +]+>",., replacement = "") %>% #去除光碟
    gsub(pattern = "[0-9]{4}/[0-9]{2}/[0-9]{2}",., replacement = "") %>% #去除日期格式:2020/01/16
    gsub(pattern = "[0-9]{4}-[0-9]{2}-[0-9]{2}",., replacement = "") %>% #去除日期格式:2020-01-16
    gsub(pattern = "[0-9]{4}年[0-9]{1,2}月[0-9]{1,2}日",., replacement = "") %>% #去除日期格式:2020年1月16日
    gsub(pattern = "[0-9]{1,2}/[0-9]{1,2}",., replacement = "") %>% #去除日期格式:01/22
    gsub(pattern = "[0-9]{1,2}-[0-9]{1,2}",., replacement = "") %>% #去除日期格式:01-22
    gsub(pattern = "[0-9]{1,2}月[0-9]{1,2}日",., replacement = "") %>% #去除日期格式:01月22日
    gsub(pattern = "[0-9]{2}:[0-9]{2}",., replacement = "") %>% #去除時間
    gsub(pattern = "新聞網址",., replacement = "") %>% 
    gsub(pattern = "\n",., replacement = "") %>% # 清理斷行符號
    gsub(pattern = "[/_.★↑｜▲△～─→──┐─╱┘●※]+?",.,replacement = "")

content_ques = removePunctuation (content_ques,ucp=T) #去除全形標點符號
content_ques = removePunctuation(content_ques) #去除半形標點符號
content_ques = stripWhitespace(content_ques) #去除空白

my_data = cbind(my_data,content_ques)

#清理標題內容
title_clear =  my_data$title %>%
    gsub(pattern = "\\[.+?\\]",., replacement = "") %>% 
    gsub(pattern = "Fw",., replacement = "") %>%
    gsub(pattern = "Re",., replacement = "") %>% 
    gsub(pattern = "[0-9]{1,2}/[0-9]{1,2}",., replacement = "") %>%
    gsub(pattern = "[0-9]{2}:[0-9]{2}",., replacement = "") %>%
    removePunctuation (.,ucp=T) %>% 
    stripWhitespace() 

my_data = cbind(my_data,title_clear)

#回覆內文數
length(grep("Re:", my_data$title))
#轉發內文數
length(grep("Fw:", my_data$title))

#標題類型個數
title_1 = regmatches(my_data$title,regexec(pattern = "\\[.+?\\]",my_data$title))
#regexec也是R裡面的正則表示式的函數之一。 regmatches可以從比對出來的結果，抽取資訊。 
title_topic=c()
for(i in 1:nrow(my_data)){
    title_topic = c(title_topic,title_1[[i]])
}

#標題類型個數
title_topic = title_topic %>% gsub(pattern = " ",., replacement = "") #去除空格
title_topic = as.factor(title_topic)
sort(summary(title_topic), decreasing = TRUE)

#停用字，設定斷詞引擎
jieba_tokenizer = worker(stop_word = "D:\\統計助教\\實習課r\\week11\\stop_words.txt")

# 設定斷詞function
gossip_tokenizer = function(t) {
    lapply(t, function(x) {
        tokens = segment(x, jieba_tokenizer)
        return(tokens)
    })
}

tokens = my_data %>% unnest_tokens(word, content_ques, token = gossip_tokenizer)
tokens = data.frame(word = tokens$word)

tokens_count = tokens %>% 
    filter(nchar(.$word)>1) %>%
    group_by(word) %>% 
    summarise(sum = n()) %>% 
    filter(sum>5) %>%
    arrange(desc(sum))

tokens_count %>% wordcloud2()
