FROM ubuntu
WORKDIR /app
ADD . .
RUN chsh -s /bin/bash
RUN apt update -y && \
    apt install -y pipx libcurl4-gnutls-dev libtinyxml2-dev libsqlite3-dev libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-gfx-dev libsdl2-mixer-dev libfmt-dev build-essential cmake
RUN cd Kangaroo && cmake . && make
RUN pipx install conan && \
    cd Core && conan install . && cd .. && cmake . make