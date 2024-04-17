//
//  WeaveGradient.swift
//  DesignSystem
//
//  Created by Jisu Kim on 2/4/24.
//

import SwiftUI

public extension Color {
    static let weaveGradientColors: [Color] = [
        Color(red: 0.45, green: 0.81, blue: 0.08),
        Color(red: 0.6, green: 0.75, blue: 0.09),
        Color(red: 0.72, green: 0.69, blue: 0.08),
        Color(red: 0.8, green: 0.62, blue: 0.04),
        Color(red: 0.81, green: 0.54, blue: 0.21),
        Color(red: 0.8, green: 0.35, blue: 0.43),
        Color(red: 0.8, green: 0.18, blue: 0.68)
    ]
}

public extension LinearGradient {
    static var weaveGradient: LinearGradient {
        return LinearGradient(
            colors: Color.weaveGradientColors,
            startPoint: UnitPoint(x: 0.02, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.69)
        )
    }
    
    static var weaveGradientReversed: LinearGradient {
        return LinearGradient(
            colors: Color.weaveGradientColors.reversed(),
            startPoint: UnitPoint(x: 0.02, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.69)
        )
    }
}

/*
 1. [Color] 내부의 컬러 요소로 Linear Gradient를 만들고
 2. 특정 point (0.0 ~ 1.0) 의 컬러값을 리턴합니다.
 -> 예를들어 point가 0.2 인 경우 Gradient의 20% 지점의 Color를 연산하여 리턴합니다.
 */
public extension Array where Element == Color {
    func colorAtPoint(at point: CGFloat) -> Color {
        
        let count = CGFloat(self.count)
        let step = 1.0 / (count - 1)
        
        let currentIndex = Swift.min(Swift.max(Int(point / step), 0), self.count - 2)
        let nextIndex = currentIndex + 1
        
        let currentPosition = step * CGFloat(currentIndex)
        let nextPosition = step * CGFloat(nextIndex)
        
        let percentageDiff = (point - currentPosition) / (nextPosition - currentPosition)
        
        // 현재 및 다음 색상 구하기
        let currentColor = self[currentIndex]
        let nextColor = self[nextIndex]
        // CIColor로 변환
        let currentCIColor = CIColor(color: UIColor(currentColor))
        let nextCIColor = CIColor(color: UIColor(nextColor))
        
        // 컴포넌트 추출
        let currentRed = currentCIColor.red
        let currentGreen = currentCIColor.green
        let currentBlue = currentCIColor.blue
        let currentAlpha = currentCIColor.alpha
        
        let nextRed = nextCIColor.red
        let nextGreen = nextCIColor.green
        let nextBlue = nextCIColor.blue
        let nextAlpha = nextCIColor.alpha
        
        // 색상 보정 및 RGBA 구하기
        let red = currentRed + (nextRed - currentRed) * percentageDiff
        let green = currentGreen + (nextGreen - currentGreen) * percentageDiff
        let blue = currentBlue + (nextBlue - currentBlue) * percentageDiff
        let alpha = currentAlpha + (nextAlpha - currentAlpha) * percentageDiff
        
        return Color(red: Double(red), green: Double(green), blue: Double(blue), opacity: Double(alpha))
    }
}
