            vim常用操作
            
       1、汉字，显示行号，高亮等配置：
            汉字问题是secureCRT的配置问题，编码格式设置成自动，字体改成可以实例显示为汉字的选项。

       2、对于vim的配置：
            2 set number //显示行号
            5 set background=dark  //背景颜色
            6 syntax on  //语法高亮显示
            7 set autoindent  //自动缩进
            8 set smartindent //智能缩进
            9 set tabstop=4  //table键为4个空格

       3、可以通过工具包对vim进行配置。对于tools 的配置
            ln -s /home/dufei-xy/tools/vim_rt/  .vim
            ln-s /home/dufei-xy/tools/vim_rt/_vimrc   .vimrc

       4、vim快捷键：
            hjkl：左，下，上，右。
            dd 删除一行  6dd 删除六行
            yy 复制一行  6yy 复制六行
            p 复制
            u  撤销
            gg=G全部规格化
            ：6  光标跳到第六行
            /yourstr  :查找yourstr在文件中。按 n（next） 下一个
            0 数字“0”，光标移至文章的开头
            G 光标移至文章的最后
            $ 光标移动至行尾
            i 在光标位置前插入字符
            a 在光标所在位置的后一个字符开始增加
            o 插入新的一行，从行首开始输入
            ESC 从输入状态退至命令状态
            x 删除光标后面的字符
            #x 删除光标后的＃个字符
            X (大写X)，删除光标前面的字符
            #X 删除光标前面的#个字符
            :%s/**/**/g替换
            \be 最近打开列表

       5、下表列出行命令模式下的一些指令
            w filename  储存正在编辑的文件为filename
            wq filename 储存正在编辑的文件为filename，并退出vi
            q! 放弃所有修改，退出vi
            set nu 显示行号
            /或? 查找，在/后输入要查找的内容
            n 与/或?一起使用，如果查找的内容不是想要找的关键字，按n或向后（与/联用）或向前（与?联用）继续查找，直到找到为止。

       6、vim +Project插件的常用操作

            登陆： 
            vim +Project 此时会打开默认的project列表。在/home/yourDIR/.vimprojects
            vim 进去后输入：“:Project filename”这里的filename为你保存的project列表。

            导入工程： \C(大写)
            将文件在水平打开多个窗口显示，打开或关闭文件夹列表：\s
            递归打开文件夹并刷新所有文件：\R
            \be 打开最近打开列表
            :e#带卡最近一次打开的文件


       7、vim ctags 插件
            ctags -R ... 创建ctags索引
            ctl + ]  跳转
            ctl + t  回到上次跳转的地方

       8、插件之minibuffer
            :tabe fn  在一个新的标签页中编辑文件fn  
            gt  切换到下一个标签页  
            gT  切换到上一个标签页  
            :tabr  切换到第一个标签页  
            :tabl  切换到最后一个标签页  
            :tabm [N]  把当前tab移动到第N个tab之后  

       9、折叠
            zc      折叠
            zC     对所在范围内所有嵌套的折叠点进行折叠
            zo      展开折叠
            zO     对所在范围内所有嵌套的折叠点展开
            在括号处zf%，创建从当前行起到对应的匹配的括号上去（（），{}，[]，<>等）。


            zi 打开关闭折叠
            zv 查看此行
            zm 关闭折叠
            zM 关闭所有
            zr 打开
            zR 打开所有
            zc 折叠当前行
            zo 打开当前折叠
            zd 删除折叠
            zD 删除所有折叠

