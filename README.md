  ##  声明：非原创，本人小白，没有这个实力，全靠添义父的打赏。感谢 [义父](https://t.me/fjanenw) 
  
  ## 1、[ 登录面板 ](https://panel.serv00.com) 删除自带的域名，然后新建一个项目（也可以不删除直接新创建）。
![Image Description](https://github.com/ryty1/alist-log/blob/main/github_images/1.png?raw=true)
       
  ## 2、登录SSH客户端安装依赖
      cd ~/domains/域名
      npm install dotenv basic-auth express

  ## 3、进入域名目录
       cd ~/domains/域名/public_nodejs
       
  ## 4、创建JS文件，复制本项目里的[ app.js ](https://github.com/ryty1/sver00-keeps-alive/blob/main/app.js)内容粘贴进去
        nano app.js

 Ctrl+S保存，然后Ctrl+X退出

  ## 5、浏览器访问  https://域名/info ，如图（如打不开可能需要挂代理）
        例如：https://fuhuo.serv00.net/info
![Image Description](https://github.com/ryty1/alist-log/blob/main/github_images/3.png?raw=true)

  ## 6、自己可以杀掉进程再刷新网页，然后再SSH端 ps aux 查询进程
  
  ## 7、进程项目可以自己DIY，默认只有 [饭奇骏](https://github.com/frankiejun/serv00-play) 大佬的 singbox 进程，至于集中自动化管理需要自己开发。
