FROM tweekmonster/vim-testbed:latest

RUN install_vim -tag v8.0.0000 -build \
                -tag v8.0.0027 -build

# the clang package includes clang-tidy
ENV PACKAGES="\
    bash \
    git \
    python \
    py-pip \
    nodejs \
    gcc \
    clang \
"
RUN apk --update add $PACKAGES && \
    rm -rf /var/cache/apk/* /tmp/* /var/tmp/*

RUN pip install vim-vint==0.3.9

RUN npm install -g eslint@3.7.1

RUN git clone https://github.com/junegunn/vader.vim vader && \
    cd vader && git checkout c6243dd81c98350df4dec608fa972df98fa2a3af
