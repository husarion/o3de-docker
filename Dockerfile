# Dockerfile based on https://gist.github.com/michalpelka/a571f914bf5c9822935f2654e45811ec

ARG ROS_DISTRO=humble

FROM husarnet/ros:${ROS_DISTRO}-ros-core

ENV O3DE_HASH=52084aee31172c0202a1de120714e811c29dd3b7
ENV O3DE_EXTRAS_HASH=3464657cd21c324ed90332a98a140e65e25fd942
ENV PROJECT_NAME=ROSbotXLDemo

ENV WORKDIR=/data/workspace
WORKDIR $WORKDIR

ARG DEBIAN_FRONTEND=noninteractive

# Setup time zone and locale data (necessary for SSL and HTTPS packages)
RUN apt-get update && DEBIAN_FRONTEND="noninteractive" apt-get -y \
    install \
    tzdata \
    locales \
    keyboard-configuration \
    && rm -rf /var/lib/apt/lists/*

RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8

# Install common tools
# deps in https://github.com/o3de/o3de/blob/development/scripts/build/build_node/Platform/Linux/package-list.ubuntu-jammy.txt
RUN apt-get update && apt-get install -y \
    bc \
    bind9-utils \
    binutils \
    ca-certificates \
    clang \
    cmake \
    file \
    firewalld \
    git \
    git-lfs \
    jq \
    kbd \
    kmod \
    less \
    lsb-release \
    libglu1-mesa-dev \
    libxcb-xinerama0 \
    libfontconfig1-dev \
    libcurl4-openssl-dev \
    libnvidia-gl-470 \
    libssl-dev \
    libxcb-xkb-dev \
    libxkbcommon-x11-dev \
    libxkbcommon-dev \
    libxcb-xfixes0-dev \
    libxcb-xinput-dev \
    libxcb-xinput0 \
    libpcre2-16-0 \
    lsof \
    net-tools \
    ninja-build \
    pciutils \
    python3-pip \
    software-properties-common \
    sudo \
    tar \
    unzip \
    vim \
    wget \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# Gem + ROS pacakges
RUN apt-get update && apt-get install -y \
    ros-$ROS_DISTRO-ackermann-msgs \
    ros-$ROS_DISTRO-control-toolbox \
    ros-$ROS_DISTRO-gazebo-msgs \
    ros-$ROS_DISTRO-joy \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-rviz2 \
    ros-$ROS_DISTRO-tf2-ros \
    ros-$ROS_DISTRO-urdfdom \
    ros-$ROS_DISTRO-vision-msgs \
    && rm -rf /var/lib/apt/lists/*

## Symlink clang version to non-versioned clang and set cc to clang
RUN update-alternatives --install /usr/bin/cc cc /usr/bin/clang 100 \
    && update-alternatives --install /usr/bin/c++ c++ /usr/bin/clang++ 100

# Install o3de
RUN git clone https://github.com/o3de/o3de.git \
    && cd o3de \
    && git checkout ${O3DE_HASH} \
    && git lfs install \
    && git lfs pull \
    && python/get_python.sh

# Install o3de-extras
RUN git clone https://github.com/o3de/o3de-extras.git \
    && cd o3de-extras \
    && git checkout ${O3DE_EXTRAS_HASH} \
    && git lfs install \
    && git lfs pull

# regiester engine and Gems from o3de-extras
RUN ./o3de/scripts/o3de.sh register --this-engine \
    && ./o3de/scripts/o3de.sh register --gem-path ./o3de-extras/Gems/ROS2 \
    && ./o3de/scripts/o3de.sh register --gem-path ./o3de-extras/Gems/RosRobotSample \
    && ./o3de/scripts/o3de.sh register --gem-path ./o3de-extras/Gems/WarehouseSample 

# create in project from template in o3de-extras
RUN ./o3de/scripts/o3de.sh create-project \
    --project-path ${WORKDIR}/${PROJECT_NAME} \
    --template-path ./o3de-extras/Templates/Ros2ProjectTemplate/ -f

WORKDIR ${WORKDIR}/${PROJECT_NAME}

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && cmake -B build/linux -S . -G "Ninja Multi-Config" -DLY_STRIP_DEBUG_SYMBOLS=ON

RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && cmake --build build/linux --config profile --target ${PROJECT_NAME} Editor AssetProcessor

# This final step takes long since they Assets will be downloading
RUN . /opt/ros/$ROS_DISTRO/setup.sh \
    && echo "This final step can take more than 1 hour. Good time for going for a coffee :)" \
    && cmake --build build/linux --config profile --target ${PROJECT_NAME}.Assets

# Installing some ros2 for navigation
RUN apt-get update && apt-get install -y \
    python3-colcon-common-extensions \
    ros-$ROS_DISTRO-cyclonedds \
    ros-$ROS_DISTRO-rmw-cyclonedds-cpp \
    ros-$ROS_DISTRO-slam-toolbox \
    ros-$ROS_DISTRO-navigation2 \
    ros-$ROS_DISTRO-nav2-bringup \
    ros-$ROS_DISTRO-pointcloud-to-laserscan \
    ros-$ROS_DISTRO-teleop-twist-keyboard \
    ros-$ROS_DISTRO-ackermann-msgs \
    ros-$ROS_DISTRO-topic-tools \
    && rm -rf /var/lib/apt/lists/*

RUN pip install python-statemachine

WORKDIR $WORKDIR

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
