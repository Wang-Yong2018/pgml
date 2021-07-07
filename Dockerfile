FROM postgres:13
ADD ./sources.list /etc/apt/sources.list
# install the python, plpython3u and postgresql server development 
RUN apt update && \
    apt -y install \
        apt-transport-https \
        procps \
        vim \
        curl \
        wget \
        zip \
        python3.7 \
        python3-pip \
        postgresql-plpython3-13 \
        postgresql-server-dev-13/buster-pgdg
        
# ad-hoc install 
RUN pip3 install -i https://mirrors.sjtug.sjtu.edu.cn/pypi/web/simple numpy pandas lightgbm sklearn pgxnclient
RUN pgxnclient install aggs_for_arrays ;\
    pgxnclient install aggs_for_vecs ;\
    pgxnclient install floatvec;\
    pgxnclient install vector


# init pgml empty script
RUN touch /docker-entrypoint-initdb.d/init_pgml.sh
