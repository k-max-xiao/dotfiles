FROM ubuntu:18.04
# install BATS for script testing
RUN apt update \
    && apt install -y git \
    && cd ../ \
    && mkdir bats \
    && cd bats \
    && git clone https://github.com/bats-core/bats-core.git \
    && cd bats-core \
    && ./install.sh /usr/local \
    && cd .. \
    && rm -r bats-core \
    && apt purge -y --auto-remove git
# create a new non-privileged user
RUN useradd --create-home --no-log-init --shell /bin/bash tester
# set to use this new user instead of dangerous root
USER tester
# create the project folder and set it as the work directory
WORKDIR /home/tester/dotfiles
# copy project files into images
COPY --chown=tester . .
