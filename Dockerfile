FROM tweekmonster/vim-testbed:latest

RUN install_vim -tag v8.0.0027 -build \
                -tag v8.1.0519 -build \
                -tag neovim:v0.2.0 -build \
                -tag neovim:v0.3.5 -build

ENV PACKAGES="\
    bash \
    git \
    python \
    py-pip \
"
RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN pip install vim-vint==0.3.15

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout 6fff477431ac3191c69a3a5e5f187925466e275a
