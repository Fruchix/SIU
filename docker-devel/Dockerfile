FROM ubuntu:22.04

RUN yes | unminimize

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    bash-completion \
    vim \
    xz-utils \
    build-essential \
    git \
    cargo \
    bsdmainutils \
    man-db \
    gcc

# separate installation to isolate layers and be able to add/remove ncurses
# without rebuilding the whole installation layer
RUN apt-get install -y libncurses5-dev libncursesw5-dev

# User setup
RUN useradd -ms /bin/bash demo_user
USER demo_user
WORKDIR /home/demo_user

COPY --chown=demo_user:demo_user . /home/demo_user/SIU

RUN ./SIU/install.sh

CMD ["bash"]
