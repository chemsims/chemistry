//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct BufferRightStack: View {

    let layout: BufferScreenLayout
    @ObservedObject var model: BufferScreenViewModel

    var body: some View {
        VStack(spacing: 0) {
            terms
            Spacer()
            beaker
        }
    }

    private var terms: some View {
        Group {
            if model.phase == .addWeakSubstance {
                BufferTerms1(components: model.weakSubstanceModel)
            } else {
                BufferTerms2(model: model.phase2Model)
            }
        }
        .frame(width: layout.common.beakyBoxWidth)
    }

    private var beaker: some View {
        BeakyBox(
            statement: model.statement,
            next: model.next,
            back: model.back,
            nextIsDisabled: false,
            settings: layout.common.beakySettings
        )
    }
}

private struct BufferTerms1: View {

    @ObservedObject var components: BufferWeakSubstanceComponents

    var body: some View {
        VStack {
            HStack {
                Text("[H]")
                AnimatingTextLine(
                    x: components.progress,
                    equation: components.concentration.primaryIon,
                    fontSize: 15,
                    formatter: TextLineUtil
                        .scientific
                )
            }

            HStack {
                Text("[A]")
                AnimatingTextLine(
                    x: components.progress,
                    equation: components.concentration.secondaryIon,
                    fontSize: 15,
                    formatter: TextLineUtil
                        .scientific)
            }

            HStack {
                Text("[HA]")
                AnimatingNumber(
                    x: components.progress,
                    equation: components.concentration.substance,
                    formatter: { $0.str(decimals: 2) })
            }

            HStack {
                Text("KA")
                AnimatingTextLine(
                    x: components.progress,
                    equation: components.kaEquation,
                    fontSize: 15,
                    formatter: TextLineUtil
                        .scientific)
            }

            HStack {
                Text("KB")
                AnimatingTextLine(
                    x: components.progress,
                    equation: components.kb,
                    fontSize: 15,
                    formatter: TextLineUtil
                        .scientific)
            }

            HStack {
                Text("PKA")
                AnimatingNumber(
                    x: components.progress,
                    equation: components.pKa,
                    formatter: { $0.str(decimals: 2) })
            }

            HStack {
                Text("pH")
                AnimatingNumber(
                    x: components.progress,
                    equation: components.ph,
                    formatter: { $0.str(decimals: 2) })
            }
        }
    }
}


private struct BufferTerms2: View {

    @ObservedObject var model: BufferSaltComponents

    var body: some View {
        VStack {
            HStack {
                Text("pH")
                AnimatingNumber(
                    x: CGFloat(model.substanceAdded),
                    equation: model.ph,
                    formatter: { $0.str(decimals: 2) }
                )
            }

            HStack {
                Text("[A]")
                AnimatingNumber(
                    x: CGFloat(model.substanceAdded),
                    equation: model.aConcentration,
                    formatter: { $0.str(decimals: 2) }
                )
            }

            HStack {
                Text("[HA]")
                AnimatingNumber(
                    x: CGFloat(model.substanceAdded),
                    equation: model.haConcentration,
                    formatter: { $0.str(decimals: 2) }
                )
            }
        }
    }
}

struct BufferRightStack_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            BufferRightStack(
                layout: BufferScreenLayout(
                    common: AcidBasesScreenLayout(
                        geometry: geo,
                        verticalSizeClass: nil,
                        horizontalSizeClass: nil
                    )
                ),
                model: BufferScreenViewModel()
            )
        }
        .padding()
        .previewLayout(.iPhone8Landscape)
    }
}
