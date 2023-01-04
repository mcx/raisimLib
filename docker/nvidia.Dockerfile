FROM nvidia/cudagl:11.4.2-base-ubuntu20.04
# FROM pytorch/pytorch:latest
ENV DEBIAN_FRONTEND=noninteractive 
ENV LANG C.UTF-8
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get install -y \
 libxcursor-dev \
 libxrandr-dev \
 libxinerama-dev \
 libxi-dev \
 mesa-common-dev \
 zip \
 unzip \
 make \
 gcc-8 \
 g++-8 \
 vulkan-utils \
 mesa-vulkan-drivers \
 pigz \
 git \
 libegl1 \
 git-lfs \
 software-properties-common \
 minizip \
 ffmpeg \
 python3-pip \
 libpython3.8-dev
ENV CXX=/usr/bin/g++-8
ENV CC=/usr/bin/gcc-8

# ==================================================================
# vulkan
# ------------------------------------------------------------------
# Force gcc 8 to avoid CUDA 10 build issues on newer base OS
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 8
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 8

# WAR for eglReleaseThread shutdown crash in libEGL_mesa.so.0 (ensure it's never detected/loaded)
# Can't remove package libegl-mesa0 directly (because of libegl1 which we need)
RUN rm /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0 /usr/lib/x86_64-linux-gnu/libEGL_mesa.so.0.0.0 /usr/share/glvnd/egl_vendor.d/50_mesa.json

COPY docker/nvidia_icd.json /usr/share/vulkan/icd.d/nvidia_icd.json
COPY docker/10_nvidia.json /usr/share/glvnd/egl_vendor.d/10_nvidia.json

# ==================================================================
# create working directories
# ------------------------------------------------------------------
ENV WORKSPACE=/root/raisim_workspace
ENV LOCAL_INSTALL=/root/raisim_build
RUN mkdir -p $WORKSPACE
RUN mkdir -p $LOCAL_INSTALL

# ==================================================================
# tools
# ------------------------------------------------------------------
RUN apt-get install -y cmake libeigen3-dev
RUN pip install torch numpy==1.23.1

# ==================================================================
# raisim
# ------------------------------------------------------------------
COPY . $WORKSPACE/raisimLib
RUN /bin/bash --login -c "cd $WORKSPACE/raisimLib && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$LOCAL_INSTALL -DRAISIM_EXAMPLE=ON -DRAISIM_PY=ON && make install -j4"

# ==================================================================
# license
# ------------------------------------------------------------------
COPY ./license/activation.raisim /root/raisim/

# ==================================================================
# add ld path
# ------------------------------------------------------------------
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$WORKSPACE/raisimLib/raisim/linux/lib
ENV PYTHONPATH=$PYTHONPATH:$WORKSPACE/raisimLib/raisim/linux/lib

# ==================================================================
# display
# ------------------------------------------------------------------
# For nvidia GUI issues
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
