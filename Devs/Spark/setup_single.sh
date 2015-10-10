#!/bin/bash

#sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk scala python-dev python-pip python-numpy python-scipy python-pandas gfortran

sudo pip install nose seaborn

sudo easy_install pymc

wget https://dl.bintray.com/sbt/debian/sbt-0.13.7.deb -P ~/Downloads
sudo dpkg -i ~/Downloads/sbt-*
sudo apt-get install sbt

wget http://www.eu.apache.org/dist/spark/spark-1.5.1/spark-1.5.1-bin-hadoop2.4.tgz -P ~/Downloads

sudo tar zxvf ~/Downloads/spark-* -C /usr/local
sudo mv /usr/local/spark-* /usr/local/spark
sudo chown -R ubuntu /usr/local/spark

echo -e "\nexport SPARK_HOME=/usr/local/spark\nexport PATH=\$PATH:\$SPARK_HOME/bin" | cat >> ~/.profile
. ~/.profile

cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh

OVERSUBSCRIPTION_FACTOR=3
WORKER_CORES=$(echo "$(nproc)*$OVERSUBSCRIPTION_FACTOR" | bc)
sed -i '6i export JAVA_HOME=/usr' $SPARK_HOME/conf/spark-env.sh
sed -i '7i export SPARK_PUBLIC_DNS="'$1'"' $SPARK_HOME/conf/spark-env.sh
sed -i '8i export SPARK_WORKER_CORES='$WORKER_CORES'' $SPARK_HOME/conf/spark-env.sh