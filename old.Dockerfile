# Debian Build
FROM debian:stable-slim

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

RUN set -x && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        aria2 \
        bash \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        locales \
        locales-all \
        make \
        mplayer \
        mpv \
        pandoc \
        python3 \
        rtmpdump \
        zip \
        && \
# Replaced as repo does not exist anymore due to a DMCA claim. We will manually update this instead
#    git clone https://github.com/ytdl-org/youtube-dl.git /src/youtube-dl && \ 
    curl -L https://yt-dl.org/downloads/2020.09.20/youtube-dl-2020.09.20.tar.gz -o youtube-dl.tar.gz && \
    mkdir -p /src/youtube-dl && \
    tar -xvzf youtube-dl.tar.gz -C /src/youtube-dl --strip-components=1 && \
    rm youtube-dl.tar.gz && \
    cd /src/youtube-dl && \
    make && \
    make install && \
    apt-get remove -y \
        curl \
        git \
        make \
        pandoc \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    youtube-dl --version && \
    update-ca-certificates && \
    rm -rf /var/lib/apt/lists/* /tmp/* /src

# Copy init script, set workdir & entrypoint
COPY init /init
WORKDIR /workdir
ENTRYPOINT ["/init"]
