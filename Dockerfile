FROM tweekmonster/vim-testbed:latest

RUN install_vim -tag v8.0.0000 -build \
                -tag v8.0.0027 -build

ENV PACKAGES="\
    git \
"
RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout c6243dd81c98350df4dec608fa972df98fa2a3af
