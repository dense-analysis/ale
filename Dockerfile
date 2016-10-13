FROM tweekmonster/vim-testbed:latest

RUN install_vim -tag v8.0.0000 -build \
                -tag v8.0.0027 -build

ENV PACKAGES="\
    git \
    python=2.7.12-r0 \
    py-pip=8.1.2-r0 \
    nodejs \
"
RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN pip install vim-vint==0.3.9

RUN npm install -g eslint@3.7.1

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout c6243dd81c98350df4dec608fa972df98fa2a3af
