FROM tweekmonster/vim-testbed:latest

RUN install_vim -tag v8.0.0027 -build \
                -tag v8.2.2401 -build \
                -tag neovim:v0.2.0 -build \
                -tag neovim:v0.4.4 -build

ENV PACKAGES="\
    bash \
    git \
    python \
    py-pip \
    grep \
    sed \
"
RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN pip install vim-vint==0.3.15

RUN git clone https://github.com/junegunn/vader.vim vader

ARG GIT_VERSION
LABEL Version=${GIT_VERSION}
LABEL Name=w0rp/ale
