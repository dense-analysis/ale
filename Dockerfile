ARG TESTBED_VIM_VERSION=24

FROM testbed/vim:${TESTBED_VIM_VERSION}

ENV PACKAGES="\
    lua5.1 \
    lua5.1-dev \
    lua5.1-busted \
    bash \
    git \
    python2 \
    python3 \
    py3-pip \
    grep \
    sed \
"
RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN install_vim -tag v8.0.0027 -build \
                -tag v9.0.0297 -build \
                -tag neovim:v0.7.0 -build \
                -tag neovim:v0.8.0 -build

RUN pip install vim-vint==0.3.21

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout c6243dd81c98350df4dec608fa972df98fa2a3af

ARG GIT_VERSION
LABEL Version=${GIT_VERSION}
LABEL Name=denseanalysis/ale
