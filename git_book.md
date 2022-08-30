# git
## git clone
第三方jvm管理
共建
##

git bash -> git config --global http.sslVerify false


切換分支
解衝突
push merge



[**pro git book**](https://git-scm.com/book/en/v2)
[中文版](https://iissnan.com/progit/html/zh-tw/ch1_3.html)
[官方中文](https://git-scm.com/book/zh-tw/v2)

### **git三種狀態**
+ 已提交(committed)
  資料己安全地存在讀者的本地端資料庫
+ 已修改(modified)
  代表著讀者已修改檔案但尚未提交到資料庫
+ 已暫存(staged)
  意謂著讀者標記已修改檔案目前的版本到下一次提供的快照


### **初次設定 Git**
Git 附帶一個名為 git config 的工具，讓你能夠取得和設定組態參數。這些設定允許你控制 Git 各方面的外觀和行為。 這些參數被存放在下列三個地方：

1. 檔案 /etc/gitconfig：裡面包含該系統所有使用者和使用者倉儲的預設設定。 如果你傳遞 --system 參數給 git config，它就會明確地從這個檔案讀取或寫入設定。

2. 檔案 ~/.gitconfig、~/.config/git/config：你的帳號專用的設定。 只要你傳遞 --global，就會明確地讓 Git 從這個檔案讀取或寫入設定

3. 任何倉儲中 Git 資料夾的 config 檔案（位於 .git/config）：這個倉儲的專用設定。

每個層級的設定皆覆蓋先前的設定，所以在 .git/config 的設定優先權高於在 /etc/gitconfig 裡的設定。


### **在現有資料夾中初始化倉儲**

``` sh
$ git init
```
到現在這步驟為止，倉儲預設沒有追蹤任何檔案


如果你的專案資料夾原本已經有檔案（不是空的），那麼建議你應該馬上追蹤這些原本就有的檔案，然後進行第一次提交。 你可以通過多次 git add 指令來追蹤完所有你想要追蹤的檔案，然後執行 git commit 提交：
``` sh
$ git add *.c
$ git add LICENSE
$ git commit -m 'initial project version'
```
到現在這步驟為止，你已經得到了一個追蹤若干檔案及第一次提交內容的 Git 倉儲。

### **克隆現有的倉儲**
若你想要取得現有 Git 倉儲的複本（例如：你想要開始協作的倉儲），那你需要使用的命令是 git clone。

克隆倉庫的命令格式是 git clone [url]。 例如：若你想克隆名為 libgit2 的 Git linkable library，可以執行下列命令：
``` sh
$ git clone https://github.com/libgit2/libgit2
```
這指令將會建立名為「libgit2」的資料夾，並在這個資料夾下初始化一個 .git 資料夾，從遠端倉儲拉取所有資料，並且取出（checkout）專案中最新的版本。 


``` sh
$ git clone https://github.com/libgit2/libgit2 mylibgit
```
這個命令做的事與上一個命令大致相同，只不過在本地創建的倉庫名字變為 mylibgit。

## 紀錄變更
工作目錄下的每個檔案不外乎兩種狀態：已追蹤、未追蹤。 「已追蹤」檔案是指那些在上次快照中的檔案：它們的狀態可能是「未修改」、「已修改」、「已預存（staged）」； 「未追蹤」則是其它以外的檔案——在工作目錄中，卻不包含在上次的快照中，也不在預存區（staging area）中的任何檔案； 當你第一次克隆（clone）一個版本庫時，所有檔案都是「已追蹤」且「未修改」，因為 Git 剛剛檢出它們並且你尚未編輯過任何檔案。

隨著你編輯某些檔案，Git 會視它們為「已修改」，因為自從上次提交以來你已經更動過它們； 你預存（stage）這些已修改檔案，然後提交所有已預存的修改內容，接著重覆這個循環。
![檔案狀態](https://git-scm.com/book/en/v2/images/lifecycle.png)

### **檢查檔案狀態**
git status 命令是用來偵測哪些檔案處在什麼樣的狀態下的主要工具； 如果你在克隆之後直接執行該命令，應該會看到類似以下內容：

``` sh
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
nothing to commit, working directory clean
```
這意味著你有一個乾淨的工作目錄——換句話說，已追蹤的檔案沒有被修改； Git 也沒有看到任何未追蹤檔案，否則它們會在這裡被列出來； 最後，這個命令告訴你目前在哪一個分支上，也告訴你它和伺服器上的同名分支是同步的。



### **預存修改過的檔案**
讓我們修改一個已追蹤檔案； 假設你修改了一個先前已追蹤的檔案 CONTRIBUTING.md，接著再次執行 git status，你會看到類似以下文字：

``` sh
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    new file:   README

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git checkout -- <file>..." to discard changes in working directory)

    modified:   CONTRIBUTING.md
```

CONTRIBUTING.md 檔案出現在「Changes not staged for commit」欄位下方——代表著位於工作目錄的已追蹤檔案已經被修改，但尚未預存； 要預存該檔案，你可執行 git add 命令；
**git add 是一個多重用途的指令——用來「開始追蹤」檔案、「預存」檔案以及做一些其它的事，像是「標記合併衝突（merge-conflicted）檔案為已解決」。 比起「把這個檔案加進專案」，把它想成「把檔案內容加入下一個提交中」會比較容易理解** 


現在，讓我們執行 git add 將 CONTRIBUTING.md 檔案預存起來，並再度執行 git status：

``` sh
$ git add CONTRIBUTING.md
$ git status
On branch master
Your branch is up-to-date with 'origin/master'.
Changes to be committed:
  (use "git reset HEAD <file>..." to unstage)

    new file:   README
    modified:   CONTRIBUTING.md
```


### **簡潔的狀態輸出**
 如果你執行 git status -s 或 git status --short，你可以從該命令得到一個相當簡單的輸出內容：

``` sh
$ git status -s
 M README
MM Rakefile
A  lib/git.rb
M  lib/simplegit.rb
?? LICENSE.txt
```
??:未追蹤<br>
A:預存區檔案<br>
M:已修改檔案<br>
標記有二個欄位——左邊欄位用來指示「預存區」狀態，右邊欄位則是「工作目錄」狀態。 所以在這個範例中，在工作目錄中的檔案 README 是已修改的，但尚未被預存；而 lib/simplegit.rb 檔案則是已修改且已預存的； Rakefile 則是曾經修改過也預存過，但之後又再次修改，所以總共有二次修改，一個有預存一個沒有。

### **檢視已預存及未預存的檔案**

git diff 指令:
瞭解兩個問題：
+ 已修改但尚未預存的內容是哪些？
+ 已預存而準備被提交的內容又有哪些？ 


### **略過預存區**
在 git commit 命令加上 -a 選項，使 Git 在提交前自動預存所有已追蹤的檔案，讓你略過 git add 步驟
``` sh
$ git commit -a
```
請留意這種使用情況：在提交之前，你並不需要執行 git add 來預存 CONTRIBUTING.md 檔案； 那是因為 -a 選項會納入所有已變更的檔案； 很方便，但請小心，有時候它會納入你並不想要的變更。



### **移除檔案**

``` sh
$ git rm
```
另一個有用的技巧是保留工作目錄的檔案，但將它從預存區中移除； 換句話說，你或許想保留在磁碟機上的檔案但不希望 Git 再繼續追蹤它； 當你忘記將某些檔案加到 .gitignore 中而且不小心預存它的時候會特別用有，像是不小心預存了一個大的日誌檔案或者一堆 .a 已編譯檔案。 加上 --cached 選項可做到這件事：

``` sh
$ git rm --cached README
```


### **移動檔案**
``` sh
$ git mv file_from file_to
``` 


### **檢視提交的歷史記錄**

``` sh
$ git clone https://github.com/schacon/simplegit-progit
```


### Git 基礎 - 復原
e.g:
``` sh
$ git commit -m 'initial commit'
$ git add forgotten_file
$ git commit --amend
```

### **將已預存的檔案移出預存區**

``` sh
$ git reset HEAD <file>
```

## **檢視你已經設定好的遠端版本庫**

``` sh
$ git remote
```
如果你克隆（clone）了一個遠端版本庫，你至少看得到「origin」——它是 Git 給定的預設簡稱，用來代表被克隆的來源。

你也可以指定 -v 選項來顯示 Git 用來讀寫遠端簡稱時所用的網址。
``` sh
$ $ git remote -v
origin	https://github.com/schacon/ticgit (fetch)
origin	https://github.com/schacon/ticgit (push)
```
### **新增遠端版本庫**
這裡將說明如何「明確地」新增一個遠端。 選一個你可以輕鬆引用的簡稱，用來代表要新增的遠端 Git 版本庫，然後執行 git remote add <簡稱> <url> 來新增它：
``` sh
$ git remote
origin
$ git remote add pb https://github.com/paulboone/ticgit
$ git remote -v
origin	https://github.com/schacon/ticgit (fetch)
origin	https://github.com/schacon/ticgit (push)
pb	https://github.com/paulboone/ticgit (fetch)
pb	https://github.com/paulboone/ticgit (push)
```

現在你可以在命令列中使用 pb 這個字串來代表整個網址； 例如，如果你想從 Paul 的版本庫中取得所有資訊，而這些資訊並不存在於你的版本庫中，你可以執行 git fetch pb：

``` sh
$ git fetch pb
remote: Counting objects: 43, done.
remote: Compressing objects: 100% (36/36), done.
remote: Total 43 (delta 10), reused 31 (delta 5)
Unpacking objects: 100% (43/43), done.
From https://github.com/paulboone/ticgit
 * [new branch]      master     -> pb/master
 * [new branch]      ticgit     -> pb/ticgit
 ```

### **從你的遠端獲取或拉取**

``` sh
$ git fetch [remote-name]
```
git fetch 命令只會下載資料到你的版本庫——它並不會自動合併你的任何工作內容，也不會自動修改你正在修改的東西；


``` sh
$ git pull
```
自動「獲取」並「合併」那個遠端分支到你目前的分支裡去
只要執行 git pull 通常就會從你最初克隆的伺服器上獲取資料，然後試著自動合併到目前的分支。

### **推送到你的遠端**

``` sh
$ git push [remote-name] [branch-name]
```
 如果你想要將 master 分支推送到 origin 伺服器上時（再次說明，克隆時通常會自動地幫你設定好 master 和 origin 這二個名稱），那麼你可以執行這個命今將所有你完成的提交（commit）推送回伺服器上。

只有在你對克隆來源的伺服器有寫入權限，並且在這個當下還沒有其它人推送過，這個命令才會成功； 如果你和其它人同時做了克隆，然後他們先推送到上游，接著換你推送到上游，毫無疑問地你的推送會被拒絕； 你必需先獲取他們的工作內容，將其整併到你之前的工作內容，如此你才會被允許推送。

### **移除或重新命名遠端**

``` sh
$ git remote rename pb paul
$ git remote
origin
paul
``` 

如果你因為某些原因想要移除一個遠端——你搬動了伺服器、或者不再使用某個特定的鏡像、或者某個貢獻者不再貢獻了——你可以執行 git remote rm：
``` 
$ git remote rm paul
$ git remote
origin
```

### **標籤**
Git 有能力對專案歷史中比較特別的時間點貼標籤，來表示其重要性。 通常大家都會用這個功能來標出發行版本，如 v1.0…等等。
[tag](https://git-scm.com/book/zh-tw/v2/Git-%E5%9F%BA%E7%A4%8E-%E6%A8%99%E7%B1%A4)



### **Git Aliases**
``` sh
$ git config --global alias.ci commit
```
只打 git ci 而不需要打 git commit


## **簡述分支**
![](https://git-scm.com/book/en/v2/images/branch-and-history.png)

### **建立新分支**
``` sh
$ git branch testing
```
![](https://git-scm.com/book/en/v2/images/two-branches.png)



### **看分支指向何處**
``` sh
$ git log --oneline --decorate
```


**分支間切換**
``` sh
$ git checkout testing
```
![](https://git-scm.com/book/en/v2/images/head-to-testing.png)


commit 後結果
``` sh
$ vim test.rb
$ git commit -a -m 'made a change'
```
![](https://git-scm.com/book/en/v2/images/advance-testing.png)


### **查看分離的分支**
``` sh
$ git log --oneline --decorate --graph --all
```

### merage
![](https://git-scm.com/book/en/v2/images/basic-branching-4.png)

``` sh
$ git checkout master
$ git merge hotfix
```
![master 被快進到 hotfix](https://git-scm.com/book/en/v2/images/basic-branching-5.png)
master 被快進到 hotfix


#### 刪除分支
``` sh
$ git branch -d hotfix
```
![](https://git-scm.com/book/en/v2/images/basic-branching-6.png)


### 另種merge情況
![](https://git-scm.com/book/en/v2/images/basic-merging-1.png)

``` sh
$ git checkout master
Switched to branch 'master'
$ git merge iss53
```
![](https://git-scm.com/book/en/v2/images/basic-merging-2.png)


### **合併衝突的基本解法**
1. status 看哪個檔案衝突
2. 手動改
3. add <br>
or<br>
``` sh
$ git mergetool
```
[參考](https://git-scm.com/book/zh-tw/v2/%E4%BD%BF%E7%94%A8-Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E5%92%8C%E5%90%88%E4%BD%B5%E7%9A%84%E5%9F%BA%E6%9C%AC%E7%94%A8%E6%B3%95)




### [**分支管理 e.g.查詢分支**](https://git-scm.com/book/zh-tw/v2/%E4%BD%BF%E7%94%A8-Git-%E5%88%86%E6%94%AF-%E5%88%86%E6%94%AF%E7%AE%A1%E7%90%86)







1. fluentd 安裝
2. apm、agent(elastic)
3. FQDN F5(nginx)
4. Maven、java、javascript
