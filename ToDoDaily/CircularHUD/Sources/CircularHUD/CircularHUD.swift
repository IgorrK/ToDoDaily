//
//  CircularHUD.swift
//  ToDoDaily
//
//  Created by Igor Kulik on 19.12.2021.
//

import SwiftUI

public struct CircularHUD: View {
    
    // MARK: - Properties
    
    public var layout: Layout
    public var style: Style
    @State private var isAnimating = false
    
    // MARK: - Lifecycle
    
    public init(layout: Layout = .default, style: Style = .default) {
        self.layout = layout
        self.style = style
    }
    
    // MARK: - View
    
    public var body: some View {
        
        ZStack {
            if let blurredBackgroundColor = style.blurredBackgroundColor {
                blurredBackgroundColor
                    .edgesIgnoringSafeArea(.all)
                    .blur(radius: 200)
            }
            
            ZStack {
                style.spinnerBackgroundColor
                
                Circle()
                    .trim(from: 0.0, to: 0.8)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [style.spinnerColor, .white.opacity(0.001)]),
                            center: .center,
                            startAngle: .degrees(320.0),
                            endAngle: .degrees(0)
                        ),
                        style: StrokeStyle(
                            lineWidth: layout.strokeWidth,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .frame(width: layout.circleRadius, height: layout.circleRadius)
                    .shadow(color: Color.black.opacity(0.1), radius: 3.0, x: 0.0, y: 3.0)
                    .rotationEffect(.degrees(isAnimating ? 360.0 : 0.0))
                    .animation(
                        Animation.linear(duration: 1.0)
                            .repeatForever(autoreverses: false)
                    )
            }
            .frame(width: layout.containerWidth, height: layout.containerHeight)
            .cornerRadius(style.backgroundCornerRadius)
            .shadow(color: style.spinnerBackgroundColor.opacity(0.3), radius: 5.0, x: 0.0, y: 5.0)
            .shadow(color: Color.black.opacity(0.1), radius: 2.0, x: 0.0, y: 2.0)
            .onAppear {
                isAnimating = true
            }
        }
    }

}

struct CircularHUD_Previews: PreviewProvider {
    static var previews: some View {
        CircularHUD()
    }
}

// MARK: - Layout & Style
public extension CircularHUD {
    
    struct Layout {
        let strokeWidth: CGFloat
        let circleRadius: CGFloat
        let containerWidth: CGFloat
        let containerHeight: CGFloat
        
        public static var `default`: Layout {
            return Layout(strokeWidth: 6.0,
                          circleRadius: 60.0,
                          containerWidth: 92.0,
                          containerHeight: 92.0)
        }
    }
    
    struct Style {
        let spinnerColor: Color
        let spinnerBackgroundColor: Color
        let blurredBackgroundColor: Color?
        let backgroundCornerRadius: CGFloat
        
        private static var systemColorScheme: UIUserInterfaceStyle { UITraitCollection.current.userInterfaceStyle }
        
        public static var `default`: Style {
            return Style(spinnerColor: .white,
                         spinnerBackgroundColor: {
                switch systemColorScheme {
                case .dark:
                    return .gray
                case .light, .unspecified:
                    return .white.opacity(0.5)
                @unknown default:
                    return .white.opacity(0.5)
                }
            }(),
                         blurredBackgroundColor: .black.opacity(0.3),
                         backgroundCornerRadius: 20.0)
        }
    }
}
