FROM nvidia/cudagl:11.4.2-base-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive 
ENV LANG C.UTF-8
RUN apt-get update && apt-get dist-upgrade -y && apt-get install -y software-properties-common minizip ffmpeg gcc-8 g++-8 python3-pip libpython3.8-dev
ENV CXX=/usr/bin/g++-8
ENV CC=/usr/bin/gcc-8

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

# ==================================================================
# raisim
# ------------------------------------------------------------------
COPY . $WORKSPACE/raisimLib
RUN cd $WORKSPACE/raisimLib && mkdir build && cd build && cmake .. -DCMAKE_INSTALL_PREFIX=$LOCAL_INSTALL -DRAISIM_EXAMPLE=ON -DRAISIM_PY=ON -DPYTHON_EXECUTABLE=$(python3 -c "import sys; print(sys.executable)") && make install -j4

# ==================================================================
# add ld path
# ------------------------------------------------------------------
ENV LD_LIBRARY_PATH="$LD_LIBRARY_PATH:$LOCAL_INSTALL/lib"
ENV PYTHONPATH="$PYTHONPATH:$LOCAL_INSTALL/lib"

# ==================================================================
# display
# ------------------------------------------------------------------
# For nvidia GUI issues
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all
