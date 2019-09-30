//
//  ContentView.swift
//  SwiftUIClosedCaptioning
//
//  Created by Daniel Bolella on 9/28/19.
//  Copyright © 2019 Daniel Bolella. All rights reserved.
//

import SwiftUI
import Speech

// This is the main SwiftUI view for this app, containing a single PlayerContainerView
struct ContentView: View {
    let videoURL = Bundle.main.url(forResource: "imac7", withExtension: "mp4")!
    
    var body: some View {
        VStack {
            Button("Give Permission"){
                SFSpeechRecognizer.requestAuthorization { authStatus in
                    switch authStatus {
                    case .authorized:
                        print("Speech recognition authorized")
                    case .denied:
                        print("Speech recognition authorization denied")
                    case .restricted:
                        print("Not available on this device")
                    case .notDetermined:
                        print("Not determined")
                    @unknown default:
                        print("Uknown status")
                    }
                }
            }
            
            PlayerContainerView(url: videoURL)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
