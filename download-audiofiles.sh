#!/bin/bash

# 
# Mach1
# Download audio files for iOS examples
# 

if [[ $PWD/ = */Pod-Mach1SpatialAPI/* ]]
then 
	echo $PWD
else
	echo "You are in the wrong directory!"
	echo $PWD
	exit
fi

mkdir -p Examples/mach1-decode-example/mach1-decode-example/Audio
mkdir -p Examples/mach1-example/Audio/Nature
mkdir -p Examples/mach1-example/Audio/SciFi
mkdir -p Examples/mach1-example/Audio/StereoTest
mkdir -p Examples/mach1-positional-example/mach1-positional-example/Audio

cd Examples/mach1-decode-example/mach1-decode-example/Audio
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/000.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/001.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/002.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/003.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/004.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/005.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/006.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/007.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/stereo.wav

cd ../../../mach1-positional-example/mach1-positional-example/Audio
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/000.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/001.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/002.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/003.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/004.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/005.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/006.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/007.aif
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/Guitar-8ch.wav
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/stereo.wav

cd ../../../mach1-example/Audio/Nature
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/Nature/Nature_Mono01.wav
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/Nature/Nature_Mono02.wav
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/Nature/Nature_Mono03.wav
cd ../SciFi
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/SciFi/SciFi_Mono01.wav
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/SciFi/SciFi_Mono02.wav
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/SciFi/SciFi_Mono03.wav
cd ../StereoTest
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_L.wav
wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_R.wav
