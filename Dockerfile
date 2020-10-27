# Build dir
FROM debian:stable-slim AS build

ENV LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    LANGUAGE=en_US:en

RUN set -x
RUN apt-get update -y
RUN apt-get install --no-install-recommends -y \
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
        zip

RUN update-ca-certificates
RUN curl -kL https://yt-dl.org/downloads/2020.09.20/youtube-dl-2020.09.20.tar.gz -o youtube-dl.tar.gz
RUN mkdir -p /src/youtube-dl
RUN tar -xvzf youtube-dl.tar.gz -C /src/youtube-dl --strip-components=1

WORKDIR /src/youtube-dl
RUN make
RUN make install

# Debian Build
FROM debian:stable-slim

COPY --from=build /usr/local/bin/youtube-dl /usr/local/bin/youtube-dl
COPY --from=build /usr/local/man/man1/youtube-dl.1 /usr/local/man/man1/youtube-dl.1
COPY --from=build /etc/bash_completion.d/youtube-dl /etc/bash_completion.d/youtube-dl

RUN apt-get update -y &&\
    apt-get install --no-install-recommends -y \
    aria2 \
    bash \
    ca-certificates \
    ffmpeg \
    mplayer \
    mpv \
    rtmpdump \
    python3 \
    && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/* && \
    ln -s /usr/local/python3 /usr/local/python && \
    youtube-dl --version && \
    update-ca-certificates

# Copy init script, set workdir & entrypoint
COPY init /init
WORKDIR /workdir
ENTRYPOINT ["/init"]
