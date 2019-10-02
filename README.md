# SwiftUIClosedCaptioning

*This project is dedicated to my Dad, who overcomes his own hearing loss everyday and inspires me to write code that can improve accessibility in tech.*

The latest version of SFSpeechRecognizer allows offline speech-to-text, amongst other new features. This project builds on the work of other devs to create a demo of how closed captioning could work with video playback.

The benefits of offline transcription is no more data usage, no more need for a data connection at all, and unlimited usage (Apple restricted transcription to 1-minute at a time and for limited hits per day). The downside is that it may not be as accurate nor have the benefit of a constantly learning cloud.

The potential applications, however, are huge for Accessibility purposes. Combined with CoreML/CreateML Speech capabilities, it can potentially open up a number of use cases.

## Authors

* **Danny Bolella** - *Initial work* - [TheDB](https://dbolella.github.io/)

## License

This project is licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details

## SUPER Acknowledgments
UI is credited to:
https://github.com/ChrisMash/AVPlayer-SwiftUI

Buffer is based on the works by:
https://github.com/peacemoon/SFSpeechRecognizerRealtimeVideoCaptioning
https://github.com/zats/SpeechRecognition
https://gist.github.com/omarojo/03d08165a1a7962cb30c17ec01f809a3

Which were all built on top of:
https://developer.apple.com/library/archive/samplecode/AudioTapProcessor/Introduction/Intro.html#//apple_ref/doc/uid/DTS40012324-Intro-DontLinkElementID_2

Phew.
