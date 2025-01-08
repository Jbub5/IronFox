#!/bin/bash

export VERSION_NAME='134.0'
export VERSION_CODE='31340000'

rootdir="$(dirname "$0")/.."
rootdir=$(realpath "$rootdir")

export TRY_FIX="$PWD"

echo "Install packages" && \
{
sudo apt update
sudo apt install -y make \
                    cmake \
                    clang-18 \
                    gyp \
                    ninja-build \
                    patch \
                    perl \
                    wget \
                    unzip \
                    xz-utils \
                    zlib1g-dev \
                    python3.9 \
                    python3.9-venv \
                    openjdk-8-jdk \
                    openjdk-17-jdk \
                    llvm-18 \
                    build-essential \
                    gcc \
                    g++ \
                    gcc-multilib

sudo rm -rf /var/cache/apt/archives
} || exit 1


echo "Setup F-Droids gradle script to be available in PATH" && \
{
mkdir -p "$HOME/bin"
wget https://gitlab.com/fdroid/fdroidserver/-/raw/master/gradlew-fdroid -O "$HOME/bin/gradle"
chmod +x "$HOME/bin/gradle"

export PATH="$HOME/bin:$PATH"
} || exit 1


echo "Disable Gradle Daemons and configuration cache" && \
{
mkdir -p ~/.gradle
echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties
echo "org.gradle.configuration-cache=false" >> ~/.gradle/gradle.properties
} || exit 1


echo "Create a new Python 3.9 virtual environment" && \
{
python3.9 -m venv env
source env/bin/activate
} || exit 1


echo "Set JDK 17" && \
{
[ -d /usr/lib/jvm/java-17-openjdk ] && export "JAVA_HOME=/usr/lib/jvm/java-17-openjdk" || \
[ -d /usr/lib/jvm/java-17-openjdk-amd64 ] && export "JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64"
} || exit 1


echo "Android SDK installation" && \
{
source ./scripts/setup-android-sdk.sh
} || exit 1

cd "$TRY_FIX"

echo "Get sources" && \
{
source ./scripts/get_sources.sh
} || exit 1


echo "Prepare build" && \
{
source scripts/paths_local.sh || echo "error: source scripts/paths_local.sh"
source ./scripts/prebuild.sh "${VERSION_NAME}" "${VERSION_CODE}"
} || exit 1


echo "Build" && \
{
source ./scripts/build.sh
} || exit 1
