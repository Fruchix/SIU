FROM ubuntu:22.04

RUN yes | unminimize

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    bash-completion \
    vim \
    xz-utils \
    libncurses5-dev libncursesw5-dev \
    build-essential \
    git \
    cargo \
    bsdmainutils \
    man-db \
    gcc


# User setup
RUN useradd -ms /bin/bash demo_user
USER demo_user
WORKDIR /home/demo_user

COPY --chown=demo_user:demo_user . /home/demo_user/SIU

WORKDIR SIU
# RUN ./install.sh

CMD ["bash"]
