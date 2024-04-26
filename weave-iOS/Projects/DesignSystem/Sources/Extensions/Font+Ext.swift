//
//  Font+Ext.swift
//  DesignSystem
//
//  Created by Jisu Kim on 1/14/24.
//

import SwiftUI
import UIKit

public enum PretendardWeight {
    case _100
    case _200
    case _300
    case _400
    case _500
    case _600
    case _700
    case _800
    case _900
    
    public var font: DesignSystemFontConvertible {
        switch self {
        case ._100:
            return DesignSystemFontFamily.Pretendard.thin
        case ._200:
            return DesignSystemFontFamily.Pretendard.extraLight
        case ._300:
            return DesignSystemFontFamily.Pretendard.light
        case ._400:
            return DesignSystemFontFamily.Pretendard.regular
        case ._500:
            return DesignSystemFontFamily.Pretendard.medium
        case ._600:
            return DesignSystemFontFamily.Pretendard.semiBold
        case ._700:
            return DesignSystemFontFamily.Pretendard.bold
        case ._800:
            return DesignSystemFontFamily.Pretendard.extraBold
        case ._900:
            return DesignSystemFontFamily.Pretendard.black
        }
    }
}

public extension Font {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> Font {
        return weight.font.font(size: size)
    }
}

public extension UIFont {
    static func pretendard(_ weight: PretendardWeight, size: CGFloat) -> UIFont {
        return weight.font.uiFont(size: size)
    }
}
