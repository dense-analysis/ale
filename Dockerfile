#############################################################################
# Base testbed image copied from:
# https://github.com/Vimjas/vim-testbed/blob/master/Dockerfile
FROM alpine:3.23 as testbed

RUN apk --no-cache upgrade

ENV PACKAGES="\
    build-base \
    linux-headers \
    cmake \
    coreutils \
    msgpack-c-dev \
    libtermkey-dev \
    libvterm-dev \
    unibilium-dev \
    ncurses-dev \
    lua5.1 \
    lua5.1-dev \
    lua5.1-lpeg \
    lua5.1-mpack \
    lua5.1-busted \
    bash \
    git \
    grep \
    sed \
    python3 \
    py3-pip \
    gettext-dev \
    libuv-dev \
    libluv \
    lua-luv-dev \
    utf8proc-dev \
    vint \
    curl \
    gettext-dev \
    libtool \
    ninja \
    tree-sitter-dev \
"

RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN adduser -h /home/vimtest -s /bin/sh -D -u 8465 vimtest

RUN mkdir -p /vim /vim-build/bin /plugins
RUN chown vimtest:vimtest /home /plugins

# Useful during tests to have these packages in a deeper layer cached already.
# RUN apk --no-cache add --virtual vim-build build-base

ADD docker/argecho.sh /vim-build/bin/argecho
ADD docker/install_vim.sh /sbin/install_vim
ADD docker/run_vim.sh /sbin/run_vim

RUN chmod +x /vim-build/bin/argecho /sbin/install_vim /sbin/run_vim

# The user directory for setup
VOLUME /home/vimtest

# Your plugin
VOLUME /testplugin

ENTRYPOINT ["/sbin/run_vim"]

#############################################################################
# ALE Test image
#
FROM testbed

RUN install_vim -tag v8.2.5172 -build \
                -tag v9.2.0329 -build \
                -tag neovim:v0.10.4 -build \
                -tag neovim:v0.12.1 -build

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout c6243dd81c98350df4dec608fa972df98fa2a3af

ARG GIT_VERSION
LABEL Version=${GIT_VERSION}
LABEL Name=denseanalysis/ale
