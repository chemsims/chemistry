//
// Reactions App
//

import SwiftUI
import ReactionsCore

struct StudentsBanner: View {

    let studentsToShow: Int
    let settings: SupportStudentsModalSettings

    var body: some View {
        students
            .frame(height: settings.bannerHeight, alignment: .bottom)
    }

    private var students: some View {
        HStack {
            Spacer(minLength: 0)
                .frame(width: settings.cornerRadius)
            student(index: 4)
            student(index: 2)
            student(index: 1)
            student(index: 3)
            student(index: 5)
            Spacer(minLength: 0)
                .frame(width: settings.cornerRadius)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text(label))
    }

    private var label: String {
        if studentsToShow == 1 {
            return "Illustration of a smiling student with a cartoon heart on their chest"
        }
        return "Illustration of \(studentsToShow) smiling students with cartoon hearts on their chest"

    }

    private func student(index: Int) -> some View {
        Image("student-\(index)")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(
                maxWidth: 100,
                maxHeight: 100
            )
            .opacity(showStudent(at: index) ? 1 : 0)
            .animation(nil)
    }

    private func showStudent(at index: Int) -> Bool {
        studentsToShow >= index
    }
}

struct StudentsBanner_Previews: PreviewProvider {
    static var previews: some View {
        GeometryReader { geo in
            StudentsBanner(
                studentsToShow: 5,
                settings: .init(geometry: geo)
            )
        }
    }
}
