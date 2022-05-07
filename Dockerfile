FROM ubuntu:18.04

# 替换为清华源
RUN sed -i 's#http://archive.ubuntu.com/#http://mirrors.tuna.tsinghua.edu.cn/#' /etc/apt/sources.list
RUN apt-get update

# 安装jdk, dos转unix命令包: dos2unix
RUN apt-get -y install default-jdk
RUN apt-get install dos2unix

# 安装python3.6和相关包
RUN apt-get -y install python3.6
RUN apt-get -y install python3.6-dev
RUN apt-get -y install python3-pip
RUN pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple pip --upgrade

# 复制当前文件夹到 /kbqa
ADD . /kbqa
WORKDIR /kbqa

# 安装python环境依赖包
RUN pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple/ && rm -rf ~/.cache/pip

# 执行dos2unix转换
RUN find /kbqa/jena/apache-jena-3.5.0/bin/ | xargs dos2unix \
    && find /kbqa/jena/apache-jena-fuseki-3.5.0/bin/ | xargs dos2unix \
    && dos2unix /kbqa/jena/apache-jena-fuseki-3.5.0/fuseki \
    && dos2unix /kbqa/jena/apache-jena-fuseki-3.5.0/fuseki-server

# 将nt格式的三元组数据以tdb(rdf格式)进行存储
RUN /kbqa/jena/apache-jena-3.5.0/bin/tdbloader --loc="/kbqa/jena/tdb" "/kbqa/kg_demo_movie.nt"

# 设置环境变量
ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 STREAMLIT_SERVER_PORT=80 FUSEKI_HOME=/kbqa/jena/apache-jena-fuseki-3.5.0

EXPOSE 80

# 启动kbqa
CMD ["./start.sh"]
