//
//  ContentView.swift
//  reactions-app
//
//  Created by Omar Fahmy on 10/11/2020.
//

import SwiftUI

struct ContentView: View {

    @ObservedObject var value = CustomSliderPreview()

    var body: some View {
        VStack {
            Text("\(value.value)")

            CustomSlider(
                value: $value.value,
                minValue: 1,
                maxValue: 2,
                handleThickness: 50,
                handleColor: Color.orangeAccent,
                handleCornerRadius: 15,
                barThickness: 5,
                barColor: Color.darkGray,
                leadingPadding: 50,
                trailingPadding: 50
            ).frame(width: 100)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
