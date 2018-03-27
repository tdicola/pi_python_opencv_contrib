# Raspberry Pi Python OpenCV &amp; OpenCV Contrib Container

Docker container with Python OpenCV &amp; OpenCV contrib compiled and installed
for the Raspberry Pi (including ARM-specific optimizations).  You can pull this
from Docker hub under the name **[tdicola/pi_python_opencv_contrib](https://hub.docker.com/r/tdicola/pi_python_opencv_contrib/)**.

This is built from the Resin.io rpi-raspbian image (a minimal
version of raspbian stretch) and includes:
-   Python 2.7 and Python 3.5 (installed from apt-get repos)
-   pip
-   NumPy
-   OpenCV + OpenCV contrib/non-free module (compiled with ARM NEON
optimizations)

The OpenCV source will be left in the /opt/opencv-{version} and
/opt/opencv_contrib-{version} folders.

Note that since this includes OpenCV's contrib module it is up to you to
determine if your use of its non-free algorithms fall within their license for
educational or non-commercial use.  Carefully consult the licenses and source
at: https://github.com/opencv/opencv_contrib

The default command for this container is to run the python3 interpreter.
You can import the cv2 module and start using OpenCV immediately.  Alternatively
you can run a shell to install other packages, then tag and save the modified
image for your own use, or even use this as a base in your own Docker containers.

There is a single build argument you can optionally specify, opencv_version.
This should be set to the version number string of OpenCV to build, like
"3.4.1".  You can find this from the releases page of OpenCV's repository:
https://github.com/opencv/opencv  It is not recommended that you change this
as earlier or later versions might require different dependencies or build
process to be followed (i.e. the instructions in this Dockerfile might not
work!).

The instructions for this build are based on the excellent blog post here:
https://www.pyimagesearch.com/2017/10/09/optimizing-opencv-on-the-raspberry-pi/

Note that if you build this container from scratch on a Pi you probably want
to increase the Pi's swapfile size as described in the post above (modify
the /etc/dphys-swapfile config and restart the dphys-swapfile.service).  Be
aware a full build will take about 1.5 hours on a Pi 3 (and much, much longer
on older or slower Pi's--sometimes 8 hours or more).
