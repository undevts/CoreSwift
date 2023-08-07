// https://www.ascii-code.com

@frozen
public enum ASCII: UInt8 {
    case null = 0
    case startOfHeading
    case startOfText
    case endOfText
    case endOfTransmission
    case enquiry
    case acknowledge
    case bell
    case backspace
    case horizontalTab
    case lineFeed = 0x0A // 10
    case verticalTabulation
    case formFeed
    case carriageReturn = 0x0D // 13
    case shiftOut
    case shiftIn
    case dataLinkEscape
    case deviceControlOne
    case deviceControlTwo
    case deviceControlThree
    case deviceControlFour = 20
    case negativeAcknowledge
    case synchronousIdle
    case endOfTransmissionBlock
    case cancel
    case endOfMedium
    case substitute
    case escape
    case fileSeparator
    case groupSeparator
    case recordSeparator = 30
    case unitSeparator
    case space
    case exclamation
    case doubleQuotes
    case numberSign
    case dollar
    case percentSign
    case ampersand
    case singleQuote
    case openParenthesis = 40
    case closeParenthesis
    case asterisk
    case plus
    case comma
    case minus
    case period
    case slash
    case zero
    case one
    case two = 50
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case colon
    case semicolon
    case lessThan = 60
    case equals
    case greaterThan
    case question
    case atSign
    case uppercaseA
    case uppercaseB
    case uppercaseC
    case uppercaseD
    case uppercaseE
    case uppercaseF = 70
    case uppercaseG
    case uppercaseH
    case uppercaseI
    case uppercaseJ
    case uppercaseK
    case uppercaseL
    case uppercaseM
    case uppercaseN
    case uppercaseO
    case uppercaseP = 80
    case uppercaseQ
    case uppercaseR
    case uppercaseS
    case uppercaseT
    case uppercaseU
    case uppercaseV
    case uppercaseW
    case uppercaseX
    case uppercaseY
    case uppercaseZ = 90
    case openingBracket
    case backslash
    case closingBracket
    case caret
    case underscore
    case graveAccent
    case lowercaseA
    case lowercaseB
    case lowercaseC
    case lowercaseD = 100
    case lowercaseE
    case lowercaseF
    case lowercaseG
    case lowercaseH
    case lowercaseI
    case lowercaseJ
    case lowercaseK
    case lowercaseL
    case lowercaseM
    case lowercaseN = 110
    case lowercaseO
    case lowercaseP
    case lowercaseQ
    case lowercaseR
    case lowercaseS
    case lowercaseT
    case lowercaseU
    case lowercaseV
    case lowercaseW
    case lowercaseX = 120
    case lowercaseY
    case lowercaseZ
    case openingBrace
    case verticalBar
    case closingBrace
    case tilde
    case delete
    case euroSign
    case unused1
    case singleLow = 130 //-9QuotationMark
    case latinSmallLetterFWithHook
    case doubleLow//-9QuotationMark
    case horizontalEllipsis
    case dagger
    case doubleDagger
    case modifierLetterCircumflexAccent
    case perMilleSign
    case latinCapitalLetterSWithCaron
    case singleLeftPointingAngleQuotation
    case latinCapitalLigatureOE = 140
    case unused2
    case latinCapitalLetterZWithCaron
    case unused3
    case unused4
    case leftSingleQuotationMark
    case rightSingleQuotationMark
    case leftDoubleQuotationMark
    case rightDoubleQuotationMark
    case bullet
    case enDash = 150
    case emDash
    case smallTilde
    case tradeMarkSign
    case latinSmallLetterSWithCaron
    case singleRightPointingAngleQuotationMark
    case latinSmallLigatureOe
    case unused
    case latinSmallLetterZWithCaron
    case latinCapitalLetterYWithDiaeresis
    case nonbreakingSpace = 160
    case invertedExclamationMark
    case centSign
    case poundSign
    case currencySign
    case yenSign
    case pipe//,BrokenVerticalBar
    case sectionSign
    case spacingDiaeresis // -Umlaut
    case copyrightSign
    case feminineOrdinalIndicator = 170
    case leftDoubleAngleQuotes
    case negation
    case softHyphen
    case registeredTradeMarkSign
    case spacingMacron // -Overline
    case degreeSign
    case plusOrMinusSign
    case superscriptTwoSquared
    case superscriptThreeCubed
    case acuteAccentSpacingAcute = 180
    case microSign
    case pilcrowSignParagraphSign
    case middleDotGeorgianComma
    case spacingCedilla
    case superscriptOne
    case masculineOrdinalIndicator
    case rightDoubleAngleQuotes
    case fractionOneQuarter
    case fractionOneHalf
    case fractionThreeQuarters = 190
    case invertedQuestionMark
    case latinCapitalLetterAWithGrave
    case latinCapitalLetterAWithAcute
    case latinCapitalLetterAWithCircumflex
    case latinCapitalLetterAWithTilde
    case latinCapitalLetterAWithDiaeresis
    case latinCapitalLetterAWithRingAbove
    case latinCapitalLetterAE
    case latinCapitalLetterCWithCedilla
    case latinCapitalLetterEWithGrave = 200
    case latinCapitalLetterEWithAcute
    case latinCapitalLetterEWithCircumflex
    case latinCapitalLetterEWithDiaeresis
    case latinCapitalLetterIWithGrave
    case latinCapitalLetterIWithAcute
    case latinCapitalLetterIWithCircumflex
    case latinCapitalLetterIWithDiaeresis
    case latinCapitalLetterETH
    case latinCapitalLetterNWithTilde
    case latinCapitalLetterOWithGrave = 210
    case latinCapitalLetterOWithAcute
    case latinCapitalLetterOWithCircumflex
    case latinCapitalLetterOWithTilde
    case latinCapitalLetterOWithDiaeresis
    case multiplicationSign
    case latinCapitalLetterOWithSlash
    case latinCapitalLetterUWithGrave
    case latinCapitalLetterUWithAcute
    case latinCapitalLetterUWithCircumflex
    case latinCapitalLetterUWithDiaeresis = 220
    case latinCapitalLetterYWithAcute
    case latinCapitalLetterTHORN
    case latinSmallLetterSharpS//-Ess-zed
    case latinSmallLetterAWithGrave
    case latinSmallLetterAWithAcute
    case latinSmallLetterAWithCircumflex
    case latinSmallLetterAWithTilde
    case latinSmallLetterAWithDiaeresis
    case latinSmallLetterAWithRingAbove
    case latinSmallLetterAe = 230
    case latinSmallLetterCWithCedilla
    case latinSmallLetterEWithGrave
    case latinSmallLetterEWithAcute
    case latinSmallLetterEWithCircumflex
    case latinSmallLetterEWithDiaeresis
    case latinSmallLetterIWithGrave
    case latinSmallLetterIWithAcute
    case latinSmallLetterIWithCircumflex
    case latinSmallLetterIWithDiaeresis
    case latinSmallLetterEth = 240
    case latinSmallLetterNWithTilde
    case latinSmallLetterOWithGrave
    case latinSmallLetterOWithAcute
    case latinSmallLetterOWithCircumflex
    case latinSmallLetterOWithTilde
    case latinSmallLetterOWithDiaeresis
    case divisionSign
    case latinSmallLetterOWithSlash
    case latinSmallLetterUWithGrave
    case latinSmallLetterUWithAcute = 250
    case latinSmallLetterUWithCircumflex
    case latinSmallLetterUWithDiaeresis
    case latinSmallLetterYWithAcute
    case latinSmallLetterThorn
    case latinSmallLetterYWithDiaeresis = 255
    
    @inlinable
    @inline(__always)
    public init(_ value: UInt8) {
        self = ASCII(rawValue: value).unsafelyUnwrapped
    }
}

extension ASCII: Comparable {
    @inlinable
    public static func <(lhs: ASCII, rhs: ASCII) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    @inlinable
    public static func >(lhs: ASCII, rhs: ASCII) -> Bool {
        lhs.rawValue > rhs.rawValue
    }

    @inlinable
    public static func >=(lhs: ASCII, rhs: ASCII) -> Bool {
        lhs.rawValue >= rhs.rawValue
    }

    @inlinable
    public static func <=(lhs: ASCII, rhs: ASCII) -> Bool {
        lhs.rawValue <= rhs.rawValue
    }

    @inlinable
    public static func <(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue < rhs
    }

    @inlinable
    public static func >(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue > rhs
    }

    @inlinable
    public static func >=(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue >= rhs
    }

    @inlinable
    public static func <=(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue <= rhs
    }

    @inlinable
    public static func <(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs < rhs.rawValue
    }

    @inlinable
    public static func >(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs > rhs.rawValue
    }

    @inlinable
    public static func >=(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs >= rhs.rawValue
    }

    @inlinable
    public static func <=(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs <= rhs.rawValue
    }

    @inlinable
    public static func ==(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs == rhs.rawValue
    }

    @inlinable
    public static func ==(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue == rhs
    }

    @inlinable
    public static func !=(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs != rhs.rawValue
    }

    @inlinable
    public static func !=(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue != rhs
    }

    @inlinable
    public static func ~=(lhs: UInt8, rhs: ASCII) -> Bool {
        lhs == rhs.rawValue
    }

    @inlinable
    public static func ~=(lhs: ASCII, rhs: UInt8) -> Bool {
        lhs.rawValue == rhs
    }
}

extension ASCII {
    /// Checks if the value is an ASCII alphabetic character:
    /// + U+0041 ‘A’ ... U+005A ‘Z’
    /// + U+0061 ‘a’ ... U+007A ‘z’
    @inlinable
    @inline(__always)
    public func isAlphabetic() -> Bool {
        switch rawValue {
        case 0x41...0x5A, 0x61...0x7A:
            return true
        default:
            return false
        }
    }

    /// Checks if the value is an ASCII alphabetic character:
    /// + U+0041 ‘A’ ... U+005A ‘Z’
    /// + U+0061 ‘a’ ... U+007A ‘z’
    /// + U+0030 ‘0’ ... U+0039 ‘9’
    @inlinable
    @inline(__always)
    public func isAlphanumeric() -> Bool {
        switch rawValue {
        case 0x30...0x39, 0x41...0x5A, 0x61...0x7A:
            return true
        default:
            return false
        }
    }

    /// Checks if the value is an ASCII uppercase character: U+0041 ‘A’ ... U+005A ‘Z’.
    @inlinable
    @inline(__always)
    public func isUppercase() -> Bool {
        switch rawValue {
        case 0x41...0x5A:
            return true
        default:
            return false
        }
    }

    /// Checks if the value is an ASCII lowercase character: U+0061 ‘a’ ... U+007A ‘z’.
    @inlinable
    @inline(__always)
    public func isLowercase() -> Bool {
        switch rawValue {
        case 0x61...0x7A:
            return true
        default:
            return false
        }
    }

    /// Checks if the value is an ASCII decimal digit: U+0030 ‘0’ ... U+0039 ‘9’.
    @inlinable
    @inline(__always)
    public func isDigit() -> Bool {
        switch rawValue {
        case 0x30...0x39:
            return true
        default:
            return false
        }
    }

    /// Checks if the value is an ASCII control character: U+0000 NUL ... U+001F UNIT SEPARATOR,
    /// or U+007F DELETE.
    ///
    /// - Note: that most ASCII whitespace characters are control characters, but SPACE is not.
    @inlinable
    @inline(__always)
    public func isControl() -> Bool {
        switch rawValue {
        case 0x00...0x1F:
            return true
        case 0x7F:
            return true
        default:
            return false
        }
    }

    /// Checks if the value is an ASCII whitespace character:
    /// U+0020 SPACE, U+0009 HORIZONTAL TAB, U+000A LINE FEED,
    /// U+000C FORM FEED, or U+000D CARRIAGE RETURN.
    ///
    /// Rust uses the WhatWG Infra Standard's [definition of ASCII
    /// whitespace][infra-aw]. There are several other definitions in
    /// wide use. For instance, [the POSIX locale][pct] includes
    /// U+000B VERTICAL TAB as well as all the above characters,
    /// but—from the very same specification—[the default rule for
    /// "field splitting" in the Bourne shell][bfs] considers *only*
    /// SPACE, HORIZONTAL TAB, and LINE FEED as whitespace.
    ///
    /// If you are writing a program that will process an existing
    /// file format, check what that format's definition of whitespace is
    /// before using this function.
    ///
    /// - SeeAlso: [infra-aw](https://infra.spec.whatwg.org/#ascii-whitespace)
    /// - SeeAlso: [pct](https://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap07.html#tag_07_03_01)
    /// - SeeAlso: [bfs](https://pubs.opengroup.org/onlinepubs/9699919799/utilities/V3_chap02.html#tag_18_06_05)
    @inlinable
    @inline(__always)
    public func isWhitespace() -> Bool {
        switch self {
        case .horizontalTab, .lineFeed, .formFeed, .carriageReturn, .space:
            return true
        default:
            return false
        }
    }
}
