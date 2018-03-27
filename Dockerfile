# Docker container for Python OpenCV (including OpenCV contrib module) on a
# Raspberry Pi.  This is built from the ResinIO rpi-raspbian image (a minimal
# version of raspbian stretch) and includes:
#   - Python 2.7 and Python 3.5 (installed from apt-get repos)
#   - pip
#   - numpy
#   - OpenCV + OpenCV contrib/non-free module (compiled with ARM NEON
# optimizations)
#
# The OpenCV source will be left in the /opt/opencv-{version} and
# /opt/opencv_contrib-{version} folders.
#
# Note that since this includes OpenCV's contrib module it is up to you to
# determine if your use of its non-free algorithms fall within their license for
# educational or non-commercial use.  Carefully consult the licenses and source
# at: https://github.com/opencv/opencv_contrib
#
# The default command for this container is to run the python3 interpreter.
# You can import the cv2 module and start using OpenCV immediately.  Alternatively
# you can run a shell to install other packages, then tag and save the modified
# image for your own use, or even use this as a base in your own Docker containers.
#
# There is a single build argument you can optionally specify, opencv_version.
# This should be set to the version number string of OpenCV to build, like
# "3.4.1".  You can find this from the releases page of OpenCV's repository:
# https://github.com/opencv/opencv  It is not recommended that you change this
# as earlier or later versions might require different dependencies or build
# process to be followed (i.e. the instructions in this Dockerfile might not
# work!).
#
# The instructions for this build are based on the excellent blog post here:
# https://www.pyimagesearch.com/2017/10/09/optimizing-opencv-on-the-raspberry-pi/
#
# Note that if you build this container from scratch on a Pi you probably want
# to increase the Pi's swapfile size as described in the post above (modify
# the /etc/dphys-swapfile config and restart the dphys-swapfile.service).  Be
# aware a full build will take about 1.5 hours on a Pi 3 (and much, much longer
# on older or slower Pi's--sometimes 8 hours or more).
#
# Author: Tony DiCola

# Base this on ResinIO's rpi-raspbian image.
FROM resin/rpi-raspbian:stretch

# Allow overriding the OpenCV version to build.
ARG opencv_version=3.4.1

# Informative labels.
LABEL description="Docker container for Python OpenCV + OpenCV contrib on a Raspberry Pi.  Based on ResinIO's rpi-raspbian image and includes support for both Python 2 and 3.  OpenCV is compiled with ARM NEON optimizations as described in: https://www.pyimagesearch.com/2017/10/09/optimizing-opencv-on-the-raspberry-pi/  Note this takes about 1.5 hours to build from scratch on a Pi 3."
LABEL maintainer="tony@tonydicola.com"

# Install dependencies and clean-up apt sources.
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gfortran \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libcanberra-gtk* \
    libgtk2.0-dev \
    libgtk-3-dev \
    libjasper-dev \
    libjpeg-dev \
    libpng-dev \
    libswscale-dev \
    libtiff5-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    pkg-config \
    python \
    python2.7-dev \
    python3-dev \
    unzip \
    wget \
  && rm -rf /var/lib/apt/lists/*

# Download OpenCV sources to /opt folder
WORKDIR /opt
RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/${opencv_version}.zip \
    && unzip opencv.zip
RUN wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/${opencv_version}.zip \
    && unzip opencv_contrib.zip

# Install pip and numpy for both Python 2 and 3.
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python3 get-pip.py \
    && pip3 install numpy
RUN python get-pip.py \
    && pip2 install numpy

# Run OpenCV's cmake and configure it with ARM optimizations.
WORKDIR /opt/opencv-${opencv_version}/build
RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/opt/opencv_contrib-${opencv_version}/modules \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF ..

# Run main compile with 4 processes (best for the Pi 3).
RUN make -j4 \
    && make install \
    && make clean

# Default to running the Python 3 interpreter command.
WORKDIR /
CMD ["python3"]
