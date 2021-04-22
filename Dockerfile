# ベースとなるimageを指定する
FROM amazonlinux:latest

# nodeとyarnをインストールするためにパッケージを追加する
RUN curl -sL https://rpm.nodesource.com/setup_14.x | bash - && \
    curl -sL https://dl.yarnpkg.com/rpm/yarn.repo | tee /etc/yum.repos.d/yarn.repo

# 最低限必要なファイルをインストールする
# bzip2 tar gcc make openssl-devel readline-devel zlib-devel はrubyをビルドする時に必要
# gcc-c++ mysql-devel はgemのインストールに必要
# nodejs yarn はwebpackの実行に必要
# 最後にキャッシュファイルを消して容量を圧縮する
RUN yum -y update && \
    yum -y install \
    git bzip2 tar gcc gcc-c++ make openssl-devel readline-devel zlib-devel mysql-devel nodejs yarn &&\
    rm -rf /var/cache/yum/*

# rbenvを入れてrubyのバージョン管理をする
RUN git clone https://github.com/sstephenson/rbenv.git /root/.rbenv && \
    git clone https://github.com/sstephenson/ruby-build.git /root/.rbenv/plugins/ruby-build && \
    /root/.rbenv/plugins/ruby-build/install.sh && \
    echo 'export PATH=$PATH' >> /root/.bashrc && \
    echo 'eval "$(rbenv init -)"' >> /root/.bashrc

# rbenvのパスを通す
ENV PATH /root/.rbenv/shims:/root/.rbenv/bin:$PATH

# rubyをインストールする
# bundlerをインストールしてgemの管理をする
RUN rbenv install 2.7.1 && \
    rbenv global 2.7.1 && \
    rbenv exec gem install bundler
