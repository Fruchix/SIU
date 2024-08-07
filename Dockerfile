FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    wget \
    vim \
    xz-utils \
    # libncurses5-dev libncursesw5-dev \
    build-essential \
    gcc


# User setup
RUN useradd -ms /bin/bash demo_user
USER demo_user
WORKDIR /home/demo_user

COPY --chown=demo_user:demo_user install_script.sh /home/demo_user/install_script.sh

# RUN /install_script.sh

CMD ["bash"]
