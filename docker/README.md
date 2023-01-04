# Docker for raisimLib
This guide assumes you have already installed [Docker](https://docs.docker.com/engine/install/ubuntu/) and [nvidia-docker2](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/install-guide.html) if you have an Nvidia GPU.

## Github
Clone the repository
```
git clone https://github.com/mcx/raisimLib.git
```

## Dockerfile
Build the Docker image from the Dockerfile

### For Nvidia GPUs
```
cd raisimLib
docker build -t raisimlib:latest -f docker/nvidia.Dockerfile .
chmod a+x docker/run_nvidia.bash
docker/run_nvidia.bash
```

## Test

### RaisimUnity
From https://raisim.com/sections/RaisimUnity.html
```
cd ~/raisim_workspace/raisimLib/raisimUnity/linux
./raisimUnity.x86_64
```

### RaisimGymTorch
From https://raisim.com/sections/RaisimGymTorch.html
```
cd ~/raisim_workspace/raisimLib/raisimGymTorch/
python3 setup.py develop
python3 raisimGymTorch/env/envs/rsg_anymal/runner.py
```

## Docker
Do the following steps to get into the container subsequently once it has been created

Run this to allow for GUI once per session (i.e. after every reboot)
```
xhost +si:localuser:$USER
xhost +local:docker
```
Then start the container and enter it
```
docker start raisimlib
docker exec -it raisimlib bash
```

## Clean Slate
To delete the container, run
```
docker rm -f raisimlib
```

