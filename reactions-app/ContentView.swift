//
//  ContentView.swift
//  reactions-app
//
//  Created by Omar Fahmy on 10/11/2020.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var model = ZeroOrderReactionViewModel()

    var body: some View {
        ZeroOrderReaction(
            beakyModel: ZeroOrderReactionNavigationViewModel(
                reactionViewModel: ZeroOrderReactionViewModel()
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
