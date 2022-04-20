//
//  File.swift
//  
//
//  Created by ERM on 20/04/2022.
//

import Foundation
import SwiftUI


public enum ViewAlignment {
    case leftTop
    case leftBottom
    case leftCenter
    case rightTop
    case rightBottom
    case rightCenter
    case center
}

public struct AlignmentableView<Content: View>: View {
    let alignment: ViewAlignment
    let spacing: CGFloat
    let content: () -> Content
    init(alignment: ViewAlignment, spacing: CGFloat = 0, @ViewBuilder _ content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = 0
        self.content = content
    }
    
    @ViewBuilder
    private func hAlignLeft() -> some View {
        HStack(spacing: spacing) {
            content()
            Spacer()
        }
    }
    
    @ViewBuilder
    private func hAlignRight() -> some View {
        HStack(spacing: spacing) {
            Spacer()
            content()
        }
    }
    
    @ViewBuilder
    private func hAlignCenter() -> some View {
        HStack(spacing: spacing) {
            Spacer()
            content()
            Spacer()
        }
    }
    
    public var body: some View {
        VStack(spacing: spacing) {
            switch alignment {
            case .leftTop:
                hAlignLeft()
                Spacer()
                
            case .leftBottom:
                Spacer()
                hAlignLeft()
                
            case .leftCenter:
                Spacer()
                hAlignLeft()
                Spacer()
                
            case .rightTop:
                hAlignRight()
                Spacer()
                
            case .rightBottom:
                Spacer()
                hAlignRight()
                
            case .rightCenter:
                Spacer()
                hAlignRight()
                Spacer()
                
            case .center:
                Spacer()
                hAlignCenter()
                Spacer()
            }
        }
    }
}
