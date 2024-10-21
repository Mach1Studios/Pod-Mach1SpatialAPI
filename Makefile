# Mach1 Spatial CocoaPods Example Setup
#
# Run via `make setup` in commandline
# to download example audio files

IOSDIR="http://dev.mach1.tech/mach1-sdk-sample-audio/ios"

# getting OS type
ifeq ($(OS),Windows_NT)
	detected_OS := Windows
else
	detected_OS := $(shell uname)
endif

setup: 
	mkdir -p Examples/mach1-decode-example/mach1-decode-example/Audio
	mkdir -p Examples/mach1-encode-example/Audio/Nature
	mkdir -p Examples/mach1-encode-example/Audio/SciFi
	mkdir -p Examples/mach1-encode-example/Audio/StereoTest
	mkdir -p Examples/mach1-positional-example/mach1-positional-example/Audio
	mkdir -p Examples/mach1-transcode-example/Audio/ACNSN3D
	mkdir -p Examples/mach1-transcode-example/Audio/FiveOneFilm_Cinema
	mkdir -p Examples/spatialaudioplayer-example/Audio
	cd Examples/mach1-decode-example/mach1-decode-example/Audio && wget -N $(IOSDIR)/mach1-decode-example/000.aif && wget -N $(IOSDIR)/mach1-decode-example/001.aif && wget -N $(IOSDIR)/mach1-decode-example/002.aif && wget -N $(IOSDIR)/mach1-decode-example/003.aif && wget -N $(IOSDIR)/mach1-decode-example/004.aif && wget -N $(IOSDIR)/mach1-decode-example/005.aif && wget -N $(IOSDIR)/mach1-decode-example/006.aif && wget -N $(IOSDIR)/mach1-decode-example/007.aif && wget -N $(IOSDIR)/mach1-decode-example/stereo.wav
	cd Examples/mach1-positional-example/mach1-positional-example/Audio && wget -N $(IOSDIR)/mach1-positional-example/000.aif && wget -N $(IOSDIR)/mach1-positional-example/001.aif && wget -N $(IOSDIR)/mach1-positional-example/002.aif && wget -N $(IOSDIR)/mach1-positional-example/003.aif && wget -N $(IOSDIR)/mach1-positional-example/004.aif && wget -N $(IOSDIR)/mach1-positional-example/005.aif && wget -N $(IOSDIR)/mach1-positional-example/006.aif && wget -N $(IOSDIR)/mach1-positional-example/007.aif && wget -N $(IOSDIR)/mach1-positional-example/Guitar-8ch.wav && wget -N $(IOSDIR)/mach1-positional-example/stereo.wav
	cd Examples/mach1-encode-example/Audio/Nature && wget -N $(IOSDIR)/mach1-encode-example/Nature/Nature_Mono01.wav && wget -N $(IOSDIR)/mach1-encode-example/Nature/Nature_Mono02.wav && wget -N $(IOSDIR)/mach1-encode-example/Nature/Nature_Mono03.wav
	cd Examples/mach1-encode-example/Audio/SciFi && wget -N $(IOSDIR)/mach1-encode-example/SciFi/SciFi_Mono01.wav && wget -N $(IOSDIR)/mach1-encode-example/SciFi/SciFi_Mono02.wav && wget -N $(IOSDIR)/mach1-encode-example/SciFi/SciFi_Mono03.wav
	cd Examples/mach1-encode-example/Audio/StereoTest && wget -N $(IOSDIR)/mach1-encode-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_L.wav && wget -N $(IOSDIR)/mach1-encode-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_R.wav
	cd Examples/mach1-transcode-example/Audio/ACNSN3D && wget -N $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-1.wav && wget -N $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-2.wav && wget -N $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-3.wav && wget -N $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-4.wav
	cd Examples/mach1-transcode-example/Audio/FiveOneFilm_Cinema && wget -N $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-1.wav && wget -N $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-2.wav && wget -N $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-3.wav && wget -N $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-4.wav && wget -N $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-5.wav && wget -N $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-6.wav
	cd Examples/spatialaudioplayer-example/Audio && wget -N $(IOSDIR)/spatialaudioplayer-example/01-1.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-2.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-3.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-4.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-5.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-6.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-7.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/01-8.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-1.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-2.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-3.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-4.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-5.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-6.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-7.aac && wget -N $(IOSDIR)/spatialaudioplayer-example/02-8.aac

build: 
	cd Examples/mach1-encode-example && pod install
	cd Examples/mach1-decode-example && pod install
	cd Examples/mach1-navigation-example && pod install
	cd Examples/mach1-positional-example && pod install
	cd Examples/mach1-transcode-example && pod install
	cd Examples/spatialaudioplayer-example && pod install

lib:
	pod lib lint

deploy: lib
	pod spec lint --allow-warnings Mach1SpatialAPI.podspec
	pod trunk push --allow-warnings --synchronous Mach1SpatialAPI.podspec