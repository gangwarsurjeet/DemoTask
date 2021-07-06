//
//  ContentAlignableLayout.swift
//

import Foundation

public enum ContentAlign {
    case left
    case right
}

public class ContentAlignableLayout: BaseLayout {
    public var contentAlign: ContentAlign = .left
}
