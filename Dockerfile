from postgres:13
ADD ./sources.list /etc/apt/sources.list
RUN apt update && \
    apt -y install \
        apt-transport-https \
        vim \
        curl \
        wget \
        zip \
        python3.7 \
        python3-pip \
        postgresql-plpython3-13
RUN pip3 install -i https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple numpy pandas

# ad-hoc install 
RUN apt -y install  postgresql-client-13/buster-pgdg
RUN pip3 install -i https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple lightgbm sklearn
