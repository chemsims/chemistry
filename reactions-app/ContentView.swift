//
//  ContentView.swift
//  reactions-app
//
//  Created by Omar Fahmy on 10/11/2020.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var model = ReactionViewModel()

    var body: some View {
        ZeroOrderReaction(
            beakyModel: ZeroOrderUserFlowViewModel(
                reactionViewModel: ReactionViewModel()
            )
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
