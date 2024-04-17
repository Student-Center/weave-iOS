//
//  WeaveIndicator.swift
//  DesignSystem
//
//  Created by 강동영 on 4/16/24.
//

import SwiftUI

public struct WeaveIndicator: View {
    @Binding var animated: Bool
    
    public init(animated: Binding<Bool>) {
        self._animated = animated
    }
    
    public var body: some View {
        TimelineView(.animation(paused: !animated)) { context in
            let director = AnimationDirector(timeInterval: context.date.timeIntervalSince1970)
            Canvas { context, size in
                let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                let centerX = rect.width * 0.5
                let centerY = rect.height * 0.5
                let scale = 0.3
                
                // MARK: Indicator
                context.drawLayer { context in
                    context.translateBy(x: centerX, y: centerY)
                    context.scaleBy(x: scale, y: scale)
                    context.draw(director.indicatorImage, at: .zero)
                }
            }
        }
    }
}

extension WeaveIndicator {
    public struct AnimationDirector {
        public var indicatorImage: Image
        
        public init(timeInterval: TimeInterval) {
            // MARK: Indicator
            let indicatorFrame: Int = {
                let framesPerSecond = 8.0 // velocity
                let totalFrames = 4.0
                let percent = timeInterval.percent(truncation: (1 / framesPerSecond) * totalFrames)
                return Int(floor(percent * totalFrames))
            }()
            
            indicatorImage = Image("Frame \(indicatorFrame + 1)", bundle: .module)
        }
    }
}

public extension BinaryFloatingPoint {
    func percent(truncation: Self) -> Self {
        assert(self.isFinite)
        assert(!truncation.isZero && truncation.isFinite)
        return self.truncatingRemainder(dividingBy: truncation) / truncation
    }
}

#Preview {
    WeaveIndicator(animated: .constant(true))
}
