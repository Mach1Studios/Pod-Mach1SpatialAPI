<a href="http://dev.mach1.tech"><img src="http://dev.mach1.xyz/images/logo_big_b_l.png"></a>

# Mach1SpatialAPI #
[![Slack Channel](https://img.shields.io/badge/Slack-Join-purple)](https://join.slack.com/t/spatialaudio/shared_invite/enQtNjk0ODE4NjQ4NjExLWQ5YWUyNWQ4NWEwMDEwZmJiNmI5MzBhYjM3OTE3NTYxYzdjZDE2YTlhZDI4OGY0ZjdkNmM1NzgxNjI5OGU4ZWE)
[![YouTube Channel](https://img.shields.io/badge/YouTube-Subscribe-red)](https://www.youtube.com/channel/UCqoFv8OnTYjkwjHeo6JDUFg)

* [LICENSE](#license)
* [SUMMARY](#summary)
* DOCUMENTATION: <a href="http://dev.mach1.tech">dev.mach1.tech</a>
* [CONTACT](#contact)

### [LICENSE](#license) ###

By downloading and/or using the Mach1 Spatial SDK, including use of any of the contents within the [binaries/](binaries),
you agree to and acknowledge the terms of use set forth by the [Mach1 Spatial SDK License](https://www.mach1.tech/license).
If you do not agree to the terms set forth by the [Mach1 Spatial SDK License](https://www.mach1.tech/license) you are not
permitted to use, link, compile and/or distribute any of the contents of this repository.

### [SUMMARY](#summary) ###

*Mach1 Spatial VVBP (Virtual Vector Based Panning) is a controlled virtual version of traditional VBAP (Vector Based Amplitude Panning) or SPS (Spatial PCM Sampling). The Mach1 Spatial formats are designed for simplicity and ease of use & implementation both for the content creators and the developers. The Mach1 Spatial audio mixes are based on only amplitude based coefficients changes for both encoding and decoding, and unlike many other spatial audio approaches, there are no additional signal altering processes (such as room modeling, delays or filters) to create coherent and accurate spatial sound fields and play them back from a first person headtracked perspective. Due to the simplicity of the format and vector space it relies on, it is also ideal for converting and carrying surround and spatial audio mixes without altering the mix to do so, making it an ideal server side audio middleman container. Bringing controlled post-produced spatial audio into new mediums easily.*

#### The Mach1 Spatial SDK includes four components and libraries: ####

* Mach1Encode lib: Encode and process input streams/audio into a Mach1Spatial VVBP format.
* Mach1Decode lib: Decode and process a Mach1Spatial VVBP format with device orientation / headtracking to output directional spatial audio.
* Mach1DecodePositional lib: Add additional optional decoding layer to decode spatial mixes with 6DOF for positional and orientational decoding.
* Mach1Transcode lib: Transcode / convert any audio format (surround/spatial) to or from a Mach1Spatial VVBP format.

## Examples

To run any of the example projects, clone the repo, and run `pod install` from the Example directory first.
or setup all the examples by running `make build` in this directory or following the README from each example.

* mach1-decode-example: Example of using Mach1Decode API and device orientation to playback a spatial soundfield.
* mach1-encode-example: Example UI of panning input mono/stereo sources to the Mach1 Spatial vector space via Mach1Encode API and playing it back simultaneously via the Mach1Decode API.
* mach1-navigation-example: Example of using TTS output as a source input for the Mach1Encode API and spatializing the playback for usecases with navigation or spatial prompts.
* mach1-positional-example: Example of using the Mach1Decode & Mach1DecodePositional APIs to playback a spatial soundfield with orientation and position data inputs.
* mach1-transcode-example: Example of converting a soundfield mix from other formats to Mach1 Spatial as an example of agnostic format ingestion and playback using the Mach1Transcode API -> Mach1Decode API.

## Installation

Mach1SpatialAPI is available internally only (release version coming soon). 
To install it, simply add the following line to your Podfile after placing the `Pod-Mach1SpatialAPI` directory in the project's parent directory:

```ruby
pod 'Mach1SpatialAPI', :path => 'Pod-Mach1SpatialAPI'
```

## Download Audio Samples

- `make setup` within this directory will download the example audiofiles

## Author

Mach1

### Contact

whatsup@mach1.tech

## License

Mach1SpatialAPI is available under the Mach1 Free Developer License Agreement. See the LICENSE file or the [Mach1 Spatial SDK License](https://www.mach1.tech/license) for more info.
