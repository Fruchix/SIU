FROM ubuntu:latest

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    vim


# User setup
RUN useradd -ms /bin/bash demo_user
USER demo_user
WORKDIR /home/demo_user

# COPY install_script.sh /install_script.sh

# RUN chmod +x /install_script.sh

# RUN /install_script.sh

CMD ["bash"]
