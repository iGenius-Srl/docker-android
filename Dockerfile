FROM openjdk:jdk
MAINTAINER iGenius

# Specify versions to use
ENV ANDROID_TARGET_SDK 25
ENV ANDROID_BUILD_TOOLS 25.0.2
ENV ANDROID_SDK_TOOLS 25.2.5
ENV NDK_RELEASE 14b

# Other environment variables
ENV ANDROID_HOME /opt/android-sdk-linux

# Install required base packages
RUN dpkg --add-architecture i386
RUN apt-get clean && apt-get -y update && apt-get -y install wget tar unzip lib32stdc++6 lib32z1 libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

# Download Android SDK Tools
RUN cd /opt \
    && wget -q https://dl.google.com/android/repository/tools_r${ANDROID_SDK_TOOLS}-linux.zip -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm -f android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

# Accept "android-sdk-license" before installing components, no need to echo y for each component
# License is valid for all the standard components in versions installed from this file
# Non-standard components: MIPS system images, preview versions, GDK (Google Glass) and Android Google TV require separate licenses, not accepted there
RUN mkdir -p ${ANDROID_HOME}/licenses
RUN echo 8933bad161af4178b1185d1a37fbf41ea5269c55 > ${ANDROID_HOME}/licenses/android-sdk-license

# Download Android SDK and required tools to be able to build
RUN sdkmanager "platform-tools"
RUN sdkmanager "platforms;android-${ANDROID_TARGET_SDK}"
RUN sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"
RUN sdkmanager "extras;android;m2repository"
RUN sdkmanager "extras;google;m2repository"
RUN sdkmanager "extras;google;google_play_services"

RUN echo y | android --silent update sdk --no-ui --all --filter extra-android-support
RUN export ANDROID_HOME=$PWD/android-sdk-linux

# Download Android NDK
RUN cd /opt && wget -q https://dl.google.com/android/repository/android-ndk-r${NDK_RELEASE}-linux-x86_64.zip -O android-ndk.zip
RUN cd /opt && unzip -q android-ndk.zip
RUN cd /opt && rm -rf android-ndk.zip

ENV ANDROID_NDK_HOME /opt/android-ndk-r${NDK_RELEASE}
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

CMD ["/bin/bash"]
