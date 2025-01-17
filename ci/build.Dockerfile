# Keep same with .devcontainer/Dockerfile

FROM envoyproxy/envoy-build-ubuntu:11efa5680d987fff33fde4af3cc5ece105015d04

ARG USERNAME=vscode
ARG USER_UID=501
ARG USER_GID=$USER_UID

ENV BUILD_DIR=/build
ENV ENVOY_STDLIB=libstdc++

ENV DEBIAN_FRONTEND=noninteractive

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - \
    | sudo tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null

RUN apt-get -y update \
    && apt-get -y install --no-install-recommends gdb libpython2.7 net-tools psmisc vim  2>&1 \
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME -G pcap -d /build \
    # [Optional] Add sudo support for non-root user
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Add golang by wbpcode
RUN export ENVOY_ARCH=$(dpkg --print-architecture) && export GOLANG_PKG=go1.15.5.linux-${ENVOY_ARCH}.tar.gz \
    && echo ${GOLANG_PKG} && wget https://dl.google.com/go/$GOLANG_PKG && tar -zxvf $GOLANG_PKG && rm $GOLANG_PKG
ENV GO_ROOT=/go

ENV DEBIAN_FRONTEND=
ENV PATH=/opt/llvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:$GO_ROOT/bin

ENV CLANG_FORMAT=/opt/llvm/bin/clang-format
