FROM ubuntu
ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Copy all project files into the container
ADD . .

# Set default shell to Bash
RUN chsh -s /bin/bash

# Update package list and install dependencies
RUN apt update -y && \
    apt install -y pipx libcurl4-gnutls-dev libtinyxml2-dev libsqlite3-dev \
                   libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-gfx-dev \
                   libsdl2-mixer-dev libfmt-dev build-essential cmake gettext libgettextpo-dev

# Ensure pipx is properly set up and install Conan
RUN pipx ensurepath && pipx install conan

# Manually set the PATH for pipx-installed binaries
ENV PATH="/root/.local/bin:${PATH}"

# Explicitly create the default Conan profile
RUN conan profile detect || conan profile new default --detect

# Build the project
RUN cd Kangaroo && cmake . && make

# Use Conan to resolve dependencies and build
RUN cd Core && conan install . --build=missing && cd .. && cmake . && make
