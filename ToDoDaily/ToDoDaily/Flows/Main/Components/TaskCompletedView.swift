//
//  TaskCompletedView.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 15.01.2022.
//

import SwiftUI

struct TaskCompletedView: View {
        @State var show = false

        var body: some View {
            VStack {
                LottieView(filename: "completed")
                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.width * 0.75)
            }
            .onAppear {
                self.show = true
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(show ? 0.5 : 0.0))
            .animation(.linear(duration: 0.5), value: show)
            .edgesIgnoringSafeArea(.all)
        }
    }

struct TaskCompletedView_Previews: PreviewProvider {
    static var previews: some View {
        TaskCompletedView()
    }
}
