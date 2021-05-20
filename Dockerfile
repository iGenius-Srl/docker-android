FROM openjdk:8-jdk
MAINTAINER iGenius

# Specify versions to use
ARG ANDROID_TARGET_SDK=30
ARG ANDROID_BUILD_TOOLS=30.0.3
ARG ANDROID_SDK_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-7302050_latest.zip"
ARG NDK_VERSION=21.1.6352462
ARG CMAKE_VERSION=3.10.2.4988404

# Other environment variables
ENV ANDROID_HOME=/opt/android-sdk-linux
ENV ANDROID_SDK_HOME=${ANDROID_HOME}
ENV ANDROID_NDK=${ANDROID_HOME}/ndk/$NDK_VERSION

ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${ANDROID_NDK}

# Install required base packages
RUN dpkg --add-architecture i386
RUN apt-get clean \
	&& apt-get -y update \
	&& apt-get -y install apt-utils wget tar unzip lib32stdc++6 lib32z1 libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

# Download Android SDK Tools
RUN cd /opt \
	&& mkdir -p ${ANDROID_HOME}/cmdline-tools \
    && wget -q "$ANDROID_SDK_TOOLS_URL" -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME}/cmdline-tools \
    && mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest \
    && rm -f android-sdk-tools.zip

RUN mkdir ~/.android && touch ~/.android/repositories.cfg

# Accepting licenses and installing platform tools, build tools, ndk, etc
RUN yes | sdkmanager --licenses \
	&& yes | sdkmanager "platform-tools" "tools" \
		"platforms;android-${ANDROID_TARGET_SDK}" \
		"build-tools;${ANDROID_BUILD_TOOLS}" \
		"extras;android;m2repository" \
		"extras;google;m2repository" \
		"extras;google;google_play_services" \
		"cmake;${CMAKE_VERSION}" \
		"ndk;$NDK_VERSION"

RUN export ANDROID_HOME=$PWD/android-sdk-linux

CMD ["/bin/bash"]
