REM
REM Mach1
REM Download audio files for web examples
REM

cd %~dp0
mkdir Examples\mach1-decode-example\mach1-decode-example\Audio
mkdir Examples\mach1-example\Audio\Nature
mkdir Examples\mach1-example\Audio\SciFi
mkdir Examples\mach1-example\Audio\StereoTest
mkdir Examples\mach1-positional-example\mach1-positional-example\Audio

cd Examples\mach1-decode-example\mach1-decode-example\Audio
powershell -Command "Invoke-WebRequest -OutFile 000.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/000.aif"
powershell -Command "Invoke-WebRequest -OutFile 001.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/001.aif"
powershell -Command "Invoke-WebRequest -OutFile 002.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/002.aif"
powershell -Command "Invoke-WebRequest -OutFile 003.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/003.aif"
powershell -Command "Invoke-WebRequest -OutFile 004.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/004.aif"
powershell -Command "Invoke-WebRequest -OutFile 005.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/005.aif"
powershell -Command "Invoke-WebRequest -OutFile 006.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/006.aif"
powershell -Command "Invoke-WebRequest -OutFile 007.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/web/mono/007.aif"
powershell -Command "Invoke-WebRequest -OutFile stereo.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-decode-example/stereo.wav"

cd ..\..\..\mach1-positional-example\mach1-positional-example\Audio
powershell -Command "Invoke-WebRequest -OutFile 000.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/000.aif"
powershell -Command "Invoke-WebRequest -OutFile 001.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/001.aif"
powershell -Command "Invoke-WebRequest -OutFile 002.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/002.aif"
powershell -Command "Invoke-WebRequest -OutFile 003.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/003.aif"
powershell -Command "Invoke-WebRequest -OutFile 004.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/004.aif"
powershell -Command "Invoke-WebRequest -OutFile 005.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/005.aif"
powershell -Command "Invoke-WebRequest -OutFile 006.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/006.aif"
powershell -Command "Invoke-WebRequest -OutFile 007.aif http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/007.aif"
powershell -Command "Invoke-WebRequest -OutFile Guitar-8ch.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/Guitar-8ch.wav"
powershell -Command "Invoke-WebRequest -OutFile stereo.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-positional-example/stereo.wav"

cd ..\..\..\mach1-example\Audio\Nature
powershell -Command "Invoke-WebRequest -OutFile Nature_Mono01.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/Nature/Nature_Mono01.wav"
powershell -Command "Invoke-WebRequest -OutFile Nature_Mono02.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/Nature/Nature_Mono02.wav"
powershell -Command "Invoke-WebRequest -OutFile Nature_Mono03.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/Nature/Nature_Mono02.wav"
cd ..\SciFi
powershell -Command "Invoke-WebRequest -OutFile SciFi_Mono01.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/SciFi/SciFi_Mono01.wav"
powershell -Command "Invoke-WebRequest -OutFile SciFi_Mono02.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/SciFi/SciFi_Mono02.wav"
powershell -Command "Invoke-WebRequest -OutFile SciFi_Mono03.wav http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/SciFi/SciFi_Mono02.wav"
cd ..\StereoTest
powershell -Command "Invoke-WebRequest -OutFile M1_SDKDemo_Electronic_Stereo_L.wav wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/StereoTest/M1_SDKDemo_Electronic_Stereo_L.wav"
powershell -Command "Invoke-WebRequest -OutFile M1_SDKDemo_Electronic_Stereo_R.wav wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/StereoTest/M1_SDKDemo_Electronic_Stereo_R.wav"
powershell -Command "Invoke-WebRequest -OutFile M1_SDKDemo_Orchestral_Stereo_L.wav wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_L.wav"
powershell -Command "Invoke-WebRequest -OutFile M1_SDKDemo_Orchestral_Stereo_R.wav wget http://dev.mach1.xyz/mach1-sdk-sample-audio/ios/mach1-example/StereoTest/M1_SDKDemo_Orchestral_Stereo_R.wav"