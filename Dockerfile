FROM tweekmonster/vim-testbed:latest

# Enable bundled treesitter needed to build NeoVim v0.5.0
# https://github.com/Vimjas/vim-testbed/issues/77
RUN sed -i 's/DEPS_CMAKE_FLAGS="-DUSE_BUNDLED=OFF"/DEPS_CMAKE_FLAGS="-DUSE_BUNDLED=OFF -DUSE_BUNDLED_TS=ON"/g' /sbin/install_vim

RUN install_vim -tag v8.0.0027 -build \
                -tag v8.2.2401 -build \
                -tag neovim:v0.2.0 -build \
                -tag neovim:v0.4.4 -build \
                -tag neovim:v0.5.0 -build

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

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout c6243dd81c98350df4dec608fa972df98fa2a3af

ARG GIT_VERSION
LABEL Version=${GIT_VERSION}
LABEL Name=w0rp/ale
