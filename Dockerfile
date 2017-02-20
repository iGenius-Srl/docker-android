FROM openjdk:jdk
MAINTAINER iGenius

# Specify versions to use
ENV ANDROID_TARGET_SDK 25
ENV ANDROID_BUILD_TOOLS 24.0.3
ENV ANDROID_SDK_TOOLS 24.4.1
ENV NDK_RELEASE 13

# Install required base packages
RUN dpkg --add-architecture i386
RUN apt-get clean && apt-get -y update && apt-get -y install wget tar unzip lib32stdc++6 lib32z1 libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

# Download Android SDK Tools
RUN cd /opt && wget -q https://dl.google.com/android/android-sdk_r${ANDROID_SDK_TOOLS}-linux.tgz -O android-sdk.tgz
RUN cd /opt && tar -xvzf android-sdk.tgz
RUN cd /opt && rm -f android-sdk.tgz

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools

# Download Android SDK and required tools to be able to build
RUN echo y | android --silent update sdk --no-ui --all --filter android-${ANDROID_TARGET_SDK}
RUN echo y | android --silent update sdk --no-ui --all --filter platform-tools
RUN echo y | android --silent update sdk --no-ui --all --filter build-tools-${ANDROID_BUILD_TOOLS}
RUN echo y | android --silent update sdk --no-ui --all --filter extra-android-support
RUN echo y | android --silent update sdk --no-ui --all --filter extra-android-m2repository
RUN echo y | android --silent update sdk --no-ui --all --filter extra-google-google_play_services
RUN echo y | android --silent update sdk --no-ui --all --filter extra-google-m2repository
RUN export ANDROID_HOME=$PWD/android-sdk-linux

# Download Android NDK
RUN cd /opt && wget -q https://dl.google.com/android/repository/android-ndk-r${NDK_RELEASE}-linux-x86_64.zip -O android-ndk.zip
RUN cd /opt && unzip -q android-ndk.zip
RUN cd /opt && rm -rf android-ndk.zip

ENV ANDROID_NDK_HOME /opt/android-ndk-r${NDK_RELEASE}
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

CMD ["/bin/bash"]
