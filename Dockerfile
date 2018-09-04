FROM openjdk:8-jdk
MAINTAINER iGenius

# Specify versions to use
ENV ANDROID_TARGET_SDK 27
ENV ANDROID_BUILD_TOOLS 27.0.3
ENV ANDROID_SDK_TOOLS_URL "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ENV NDK_RELEASE 17b

# Other environment variables
ENV ANDROID_HOME /opt/android-sdk-linux

# Install required base packages
RUN dpkg --add-architecture i386
RUN apt-get clean && apt-get -y update && apt-get -y install apt-utils wget tar unzip lib32stdc++6 lib32z1 libc6:i386 libstdc++6:i386 libgcc1:i386 libncurses5:i386 libz1:i386

# Download Android SDK Tools
RUN cd /opt \
    && wget -q "$ANDROID_SDK_TOOLS_URL" -O android-sdk-tools.zip \
    && unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} \
    && rm -f android-sdk-tools.zip

ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

RUN mkdir ~/.android && touch ~/.android/repositories.cfg
#accepting licenses
RUN yes | sdkmanager --licenses

# Download Android SDK and required tools to be able to build
RUN sdkmanager "platform-tools" "tools"
RUN sdkmanager "platforms;android-${ANDROID_TARGET_SDK}"
RUN sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"
RUN sdkmanager "extras;android;m2repository" "extras;google;m2repository"
RUN sdkmanager "extras;google;google_play_services"

RUN sdkmanager --update
RUN yes | sdkmanager --licenses

RUN export ANDROID_HOME=$PWD/android-sdk-linux

# Download Android NDK
RUN cd /opt && wget -q https://dl.google.com/android/repository/android-ndk-r${NDK_RELEASE}-linux-x86_64.zip -O android-ndk.zip
RUN cd /opt && unzip -q android-ndk.zip
RUN cd /opt && rm -rf android-ndk.zip

ENV ANDROID_NDK_HOME /opt/android-ndk-r${NDK_RELEASE}
ENV PATH ${PATH}:${ANDROID_NDK_HOME}

CMD ["/bin/bash"]
