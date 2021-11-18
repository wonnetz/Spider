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

##! From this point on, you need to have the following files in your cwd !##
##! core-site.xml, hdfs-site.xml, mapred-site.xml, and yarn-site.xml !##

# Edits core-site.xml
cp core-site.xml $HADOOP_HOME/etc/hadoop
sed -i "s+<value>/home/ubuntu/Softwares/tmpdata</name>+<value>/home/$HOST/softwares/tmpdata</value>+g" $HADOOP_HOME/etc/core-site.xml

# Edits hdfs-site.xml
cp hdfs-site.xml $HADOOP_HOME/etc/hadoop
sed -i "s+<value>/home/ubuntu/Softwares/dfsdata/namenode</value>+<value>/home/$HOST/hadoopdata/hdfs/namenode</value>" $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i "s+<value>/home/ubuntu/Softwares/dfsdata/datanode</value>+<value>/home/$HOST/hadoopdata/hdfs/datanode</value>" $HADOOP_HOME/etc/hadoop/hdfs-site.xml

# Edits mapred-site.xml
cp mapred-site.xml $HADOOP_HOME/etc/hadoop

# Edits yarn-site.xml
cp yarn-site.xml $HADOOP_HOME/etc/hadoop

# Final step! 
# Formats the cluster
hdfs namenode -format

# From here we should be able to run start-all.sh
