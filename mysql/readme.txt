mysql的安装推荐使用yum源的方式安装。
参考文档：http://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/
yum源地址：http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
1、添加源
sudo rpm -Uvh mysql-community-release-el7-5.noarch.rpm
2、安装mysqlserver
yum install mysql-community-server
3、启动服务
service mysqld start
4、设置密码
mysql_secure_installation





===========
常用设置
设置数据库或表编码方式：
create database `DB` character set `utf-8` collate `utf8_general_ci`;
create table tab (`name` varchar(10),`age` int)default charset=utf8;

创建用户，赋予权限
insert into mysql.user(Host,User,Password) values("localhost","dev",password("123"));
flush privileges
赋予数据库权限
grant all privileges on DBname.* to dev@localhost identified by '123';
撤销权限
revoke all on DBname.* from dev@localhost;
删除用户
drop user dev@localhost; 