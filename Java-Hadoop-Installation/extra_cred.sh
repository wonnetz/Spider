#!/bin/bash
# This is a shell script that installs java and hadoop

# Basic Java Installation
sudo apt update
sudo apt install openjdk-11-jdk

# Basic Hadoop Installation
wget https://downloads.apache.org/hadoop/common/hadoop-3.3.1/hadoop-3.3.1.tar.gz
tar -xvzf hadoop-3.3.1.tar.gz 
DUMMY=$(dirname $(dirname $(readlink -f $(which java))))
echo '
# Setting the file paths in bashrc
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_HOME=/home/hadoop/hadoop
export HADOOP_INSTALL=$HADOOP_HOME
export HADOOP_MAPRED_HOME=$HADOOP_HOME
export HADOOP_COMMON_HOME=$HADOOP_HOME
export HADOOP_HDFS_HOME=$HADOOP_HOME
export HADOOP_YARN_HOME=$HADOOP_HOME
export HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
export PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin
export HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native"'>> ~/.bashrc

source ~/.bashrc

# Setting the file paths in hadoop-env.sh
echo '
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64' >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh 

# Hadoop Configurations
mkdir -p ~/hadoopdata/hdfs/namenode
mkdir -p ~/hadoopdata/hdfs/datanode

HOST=$(hostname)
mkdir -p /softwares/tmpdata

# Edits core-site.xml
sed -i "s+<configuration>+ +g" $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i "s+</configuration>+ +g" $HADOOP_HOME/etc/hadoop/core-site.xml
echo '
<configuration>
    <property>
        <name>fs.defaultFS</name>
        <value>hdfs://localhost:9000</value>
    </property>
</configuration>' >> $HADOOP_HOME/etc/hadoop/core-site.xml

# Edits hdfs-site.xml
sed -i "s+<configuration>+ +g" $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i "s+</configuration>+ +g" $HADOOP_HOME/etc/hadoop/hdfs-site.xml
echo '
<configuration>
    <property>
        <name>dfs.replication</name>
        <value>1</value>
    </property>
</configuration>' >> $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# Edits mapred-site.xml
sed -i "s+<configuration>+ +g" $HADOOP_HOME/etc/hadoop/mapred-site.xml
sed -i "s+</configuration>+ +g" $HADOOP_HOME/etc/hadoop/mapred-site.xml
echo '
<configuration>
    <property>
        <name>mapreduce.framework.name</name>
        <value>yarn</value>
    </property>
    <property>
        <name>mapreduce.application.classpath</name>
        <value>$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/*:$HADOOP_MAPRED_HOME/share/hadoop/mapreduce/lib/*</value>
    </property>
</configuration>' >> $HADOOP_HOME/etc/hadoop/mapred-site.xml

# Edits yarn-site.xml
sed -i "s+<configuration>+ +g" $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i "s+</configuration>+ +g" $HADOOP_HOME/etc/hadoop/yarn-site.xml
echo '
<configuration>
    <property>
        <name>yarn.nodemanager.aux-services</name>
        <value>mapreduce_shuffle</value>
    </property>
    <property>
        <name>yarn.nodemanager.env-whitelist</name>
        <value>JAVA_HOME,HADOOP_COMMON_HOME,HADOOP_HDFS_HOME,HADOOP_CONF_DIR,CLASSPATH_PREPEND_DISTCACHE,HADOOP_YARN_HOME,HADOOP_HOME,PATH,LANG,TZ,HADOOP_MAPRED_HOME</value>
    </property>
</configuration>' >> $HADOOP_HOME/etc/hadoop/yarn-site.xml

# Final step! 
# Formats the cluster
hdfs namenode -format

# From here we should be able to run start-all.sh
