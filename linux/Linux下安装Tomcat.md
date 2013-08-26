Tomcat是一个免费的开源的Serlvet容器，它是Apache基金会的Jakarta项目中的一个核心项目，由Apache，Sun和其它一些公司及个人共同开发而成。由于有了Sun的参与和支持，最新的Servlet和Jsp规范总能在Tomcat中得到体现。

Tomcat是稳固的独立的Web服务器与Servlet Container，不过，其Web服务器的功能则不如许多更健全的Web服务器完整，如Apache Web服务器(举例来说，Tomcat没有大量的选择性模块)。不过，Tomcat是自由的开源软件，而且有许多高手致力于其发展。

在安装Tomcat之前需要安装j2sdk(Java 2 Software Development Kit)，也就是JDK

◆1、安装JDK的步骤如下：

1）下载j2sdk ，如jdk-6u1-linux-i586-rpm.bin

2）在终端中转到jdk-6u1-linux-i586-rpm.bin所在的目录，输入命令

#chmod +755 jdk-6u1-linux-i586-rpm.bin；//添加执行的权限。

3）执行命令

#./jdk-6u1-linux-i586-rpm.bin；//生成jdk-6u1-linux-i586.rpm的文件。

4）执行命令

#chmod +755 jdk-6u1-linux-i586.rpm；//给jdk-6u1-linux-i586.rpm添加执行的权限。 

5）执行命令

#rpm –ivh jdk-6u1-linux-i586.rpm ； //安装jdk。

6）安装界面会出现授权协议，按Enter键接受，把jdk安装在/usr/java/jdk1.6.0_01。

7)设置环境变量，在 /etc/profile中加入如下内容(可以使用vi进行编辑profile)：

JAVA_HOME=/usr/java/jdk1.6.0_01
CLASSPATH=$JAVA_HOME/lib:$JAVA_HOME/jre/lib
PATH=$PATH:$JAVA_HOME/bin:$JAVA_HOME/jre/bin
export PATH CLASSPATH JAVA_HOME

8)在终端执行命令java –version，jdk的版本为jdk1.6.0_01则表示jdk已成功安装。

◆2、安装Tomcat

1）下载apache-tomcat-6.0.10.tar.gz

2）#tar -zxvf apache-tomcat-6.0.10.tar.gz ；//解压

3）#cp -R apache-tomcat-6.0.10 /usr/local/tomcat ；//拷贝apache-tomcat-6.0.10到/usr/local/下并重命名为tomcat

4） /usr/local/tomcat/bin/startup.sh； //启动tomcat

显示 Using CATALINA_BASE: /usr/local/tomcat

Using CATALINA_HOME: /usr/local/tomcat

Using CATALINA_TEMDIR: /usr/local/tomcat/temp

Using JAVA_HOME: /usr/java/jdk1.6.0_01

到此tomcat已经安装完成，现在使用浏览器访问 http://localhost:8080，出现tomcat默认页面，说明已经安装成功。
