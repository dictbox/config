mysql�İ�װ�Ƽ�ʹ��yumԴ�ķ�ʽ��װ��
�ο��ĵ���http://dev.mysql.com/doc/mysql-yum-repo-quick-guide/en/
yumԴ��ַ��http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
1�����Դ
sudo rpm -Uvh mysql-community-release-el7-5.noarch.rpm
2����װmysqlserver
yum install mysql-community-server
3����������
service mysqld start
4����������
mysql_secure_installation





===========
��������
�������ݿ�����뷽ʽ��
create database `DB` character set `utf-8` collate `utf8_general_ci`;
create table tab (`name` varchar(10),`age` int)default charset=utf8;

�����û�������Ȩ��
insert into mysql.user(Host,User,Password) values("localhost","dev",password("123"));
flush privileges
�������ݿ�Ȩ��
grant all privileges on DBname.* to dev@localhost identified by '123';
����Ȩ��
revoke all on DBname.* from dev@localhost;
ɾ���û�
drop user dev@localhost; 