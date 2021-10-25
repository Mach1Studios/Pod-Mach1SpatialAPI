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
ifeq ($(detected_OS),Darwin)
	cd Examples/mach1-decode-example/mach1-decode-example/Audio && wget $(IOSDIR)/mach1-decode-example/000.aif && wget $(IOSDIR)/mach1-decode-example/001.aif && wget $(IOSDIR)/mach1-decode-example/002.aif && wget $(IOSDIR)/mach1-decode-example/003.aif && wget $(IOSDIR)/mach1-decode-example/004.aif && wget $(IOSDIR)/mach1-decode-example/005.aif && wget $(IOSDIR)/mach1-decode-example/006.aif && wget $(IOSDIR)/mach1-decode-example/007.aif && wget $(IOSDIR)/mach1-decode-example/stereo.wav
	cd Examples/mach1-positional-example/mach1-positional-example/Audio && wget $(IOSDIR)/mach1-positional-example/000.aif && wget $(IOSDIR)/mach1-positional-example/001.aif && wget $(IOSDIR)/mach1-positional-example/002.aif && wget $(IOSDIR)/mach1-positional-example/003.aif && wget $(IOSDIR)/mach1-positional-example/004.aif && wget $(IOSDIR)/mach1-positional-example/005.aif && wget $(IOSDIR)/mach1-positional-example/006.aif && wget $(IOSDIR)/mach1-positional-example/007.aif && wget $(IOSDIR)/mach1-positional-example/Guitar-8ch.wav && wget $(IOSDIR)/mach1-positional-example/stereo.wav
	cd Examples/mach1-encode-example/Audio/Nature && wget $(IOSDIR)/mach1-encode-example/Nature/Nature_Mono01.wav && wget $(IOSDIR)/mach1-encode-example/Nature/Nature_Mono02.wav && wget $(IOSDIR)/mach1-encode-example/Nature/Nature_Mono03.wav
	cd Examples/mach1-encode-example/Audio/SciFi && wget $(IOSDIR)/mach1-encode-example/SciFi/SciFi_Mono01.wav && wget $(IOSDIR)/mach1-encode-example/SciFi/SciFi_Mono02.wav && wget $(IOSDIR)/mach1-encode-example/SciFi/SciFi_Mono03.wav
	cd Examples/mach1-encode-example/Audio/StereoTest && wget $(IOSDIR)/mach1-encode-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_L.wav && wget $(IOSDIR)/mach1-encode-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_R.wav
	cd Examples/mach1-transcode-example/Audio/ACNSN3D && wget $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-1.wav && wget $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-2.wav && wget $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-3.wav && wget $(IOSDIR)/mach1-transcode-example/ACNSN3D/guitar-acnsn3d-4.wav
	cd Examples/mach1-transcode-example/Audio/FiveOneFilm_Cinema && wget $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-1.wav && wget $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-2.wav && wget $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-3.wav && wget $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-4.wav && wget $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-5.wav && wget $(IOSDIR)/mach1-transcode-example/FiveOneFilm_Cinema/guitar-51Film-6.wav
endif
ifeq ($(detected_OS),Windows)
endif

build: setup
	cd Examples/mach1-encode-example && pod install
	cd Examples/mach1-decode-example && pod install
	cd Examples/mach1-positional-example && pod install
	cd Examples/mach1-transcode-example && pod install