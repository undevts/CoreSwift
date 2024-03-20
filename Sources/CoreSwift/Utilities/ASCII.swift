// https://www.ascii-code.com
// https://symbl.cc/en/unicode/blocks/basic-latin/
// https://symbl.cc/en/unicode/blocks/latin-1-supplement/
// Rust https://doc.rust-lang.org/std/ascii/enum.Char.html

/// One of the 256 Unicode characters from U+0000 through U+00FF,
/// often known as the [ASCII] subset.
///
/// Officially, this is the first [block] in Unicode, _Basic Latin_.
/// For details, see the [*C0 Controls and Basic Latin*][chart] code chart.
///
/// This block was based on older 7-bit character code standards such as
/// ANSI X3.4-1977, ISO 646-1973, and [NIST FIPS 1-2].
///
/// # When to use this
///
/// The main advantage of this subset is that it's always valid UTF-8.  As such,
/// the `&[ascii::Char]` -> `&str` conversion function (as well as other related
/// ones) are O(1): *no* runtime checks are needed.
///
/// If you're consuming strings, you should usually handle Unicode and thus
/// accept `str`s, not limit yourself to `ascii::Char`s.
///
/// However, certain formats are intentionally designed to produce ASCII-only
/// output in order to be 8-bit-clean.  In those cases, it can be simpler and
/// faster to generate `ascii::Char`s instead of dealing with the variable width
/// properties of general UTF-8 encoded strings, while still allowing the result
/// to be used freely with other Rust things that deal in general `str`s.
///
/// For example, a UUID library might offer a way to produce the string
/// representation of a UUID as an `[ascii::Char; 36]` to avoid memory
/// allocation yet still allow it to be used as UTF-8 via `as_str` without
/// paying for validation (or needing `unsafe` code) the way it would if it
/// were provided as a `[u8; 36]`.
///
/// # Layout
///
/// This type is guaranteed to have a size and alignment of 1 byte.
///
/// # Names
///
/// The variants on this type are [Unicode names][NamesList] of the characters
/// in upper camel case, with a few tweaks:
/// - For `<control>` characters, the primary alias name is used.
/// - `LATIN` is dropped, as this block has no non-latin letters.
/// - `LETTER` is dropped, as `CAPITAL`/`SMALL` suffices in this block.
/// - `DIGIT`s use a single digit rather than writing out `ZERO`, `ONE`, etc.
///
/// [ASCII]: https://www.unicode.org/glossary/index.html#ASCII
/// [block]: https://www.unicode.org/glossary/index.html#block
/// [chart]: https://www.unicode.org/charts/PDF/U0000.pdf
/// [NIST FIPS 1-2]: https://nvlpubs.nist.gov/nistpubs/Legacy/FIPS/fipspub1-2-1977.pdf
/// [NamesList]: https://www.unicode.org/Public/15.0.0/ucd/NamesList.txt
@frozen
public enum ASCII: UInt8 {
    /// U+0000, 0x0000, not printable.
    case null = 0
    /// U+0001, 0x0001, not printable.
    case startOfHeading
    /// U+0002, 0x0002, not printable.
    case startOfText
    /// U+0003, 0x0003, not printable.
    case endOfText
    /// U+0004, 0x0004, not printable.
    case endOfTransmission
    /// U+0005, 0x0005, not printable.
    case enquiry
    /// U+0006, 0x0006, not printable.
    case acknowledge
    /// U+0007, 0x0007, not printable.
    case bell
    /// U+0008, 0x0008, not printable.
    case backspace
    /// U+0009, 0x0009, not printable.
    case horizontalTab
    /// U+0010, 0x000A, not printable.
    case lineFeed = 10
    /// U+0011, 0x000B, not printable.
    case lineTabulation
    /// U+0012, 0x000C, not printable.
    case formFeed
    /// U+0013, 0x000D, not printable.
    case carriageReturn
    /// U+0014, 0x000E, not printable.
    case shiftOut
    /// U+0015, 0x000F, not printable.
    case shiftIn
    /// U+0016, 0x0010, not printable.
    case dataLinkEscape
    /// U+0017, 0x0011, not printable.
    case deviceControlOne
    /// U+0018, 0x0012, not printable.
    case deviceControlTwo
    /// U+0019, 0x0013, not printable.
    case deviceControlThree
    /// U+0020, 0x0014, not printable.
    case deviceControlFour = 20
    /// U+0021, 0x0015, not printable.
    case negativeAcknowledge
    /// U+0022, 0x0016, not printable.
    case synchronousIdle
    /// U+0023, 0x0017, not printable.
    case endOfTransmissionBlock
    /// U+0024, 0x0018, not printable.
    case cancel
    /// U+0025, 0x0019, not printable.
    case endOfMedium
    /// U+0026, 0x001A, not printable.
    case substitute
    /// U+0027, 0x001B, not printable.
    case escape
    /// U+0028, 0x001C, not printable.
    case informationSeparatorFour
    /// U+0029, 0x001D, not printable.
    case informationSeparatorThree
    /// U+0030, 0x001E, not printable.
    case informationSeparatorTwo = 30
    /// U+0031, 0x001F, not printable.
    case informationSeparatorOne
    /// U+0032, 0x0020, ' '.
    case space
    /// U+0033, 0x0021, '!'.
    case exclamationMark
    /// U+0034, 0x0022, '!'.
    case quotationMark
    /// U+0035, 0x0023, '#'.
    case numberSign
    /// U+0036, 0x0024, '$'.
    case dollarSign
    /// U+0037, 0x0025, '%'.
    case percentSign
    /// U+0038, 0x0026, '&'.
    case ampersand
    /// U+0039, 0x0027, '.
    case apostrophe
    /// U+0040, 0x0028, '('.
    case leftParenthesis = 40
    /// U+0041, 0x0029, ')'.
    case rightParenthesis
    /// U+0042, 0x002A, '*'.
    case asterisk
    /// U+0043, 0x002B, '+'.
    case plusSign
    /// U+0044, 0x002C, ','.
    case comma
    /// U+0045, 0x002D, '-'.
    case hyphenMinus
    /// U+0046, 0x002E, '.'.
    case fullStop
    /// U+0047, 0x002F, '/'.
    case solidus
    /// U+0048, 0x0030, '0'.
    case digit0
    /// U+0049, 0x0031, '1'.
    case digit1
    /// U+0050, 0x0032, '2'.
    case digit2 = 50
    /// U+0051, 0x0033, '3'.
    case digit3
    /// U+0052, 0x0034, '4'.
    case digit4
    /// U+0053, 0x0035, '5'.
    case digit5
    /// U+0054, 0x0036, '6'.
    case digit6
    /// U+0055, 0x0037, '7'.
    case digit7
    /// U+0056, 0x0038, '8'.
    case digit9
    /// U+0057, 0x0039, '9'.
    case digit10
    /// U+0058, 0x003A, ':'.
    case colon
    /// U+0059, 0x003B, ';'.
    case semicolon
    /// U+0060, 0x003C, '<'.
    case lessThanSign = 60
    /// U+0061, 0x003D, '='.
    case equalsSign
    /// U+0062, 0x003E, '>'.
    case greaterThanSign
    /// U+0063, 0x003F, '?'.
    case questionMark
    /// U+0064, 0x0040, '@'.
    case commercialAt
    /// U+0065, 0x0041, 'A'.
    case capitalA
    /// U+0066, 0x0042, 'B'.
    case capitalB
    /// U+0067, 0x0043, 'C'.
    case capitalC
    /// U+0068, 0x0044, 'D'.
    case capitalD
    /// U+0069, 0x0045, 'E'.
    case capitalE
    /// U+0070, 0x0046, 'F'.
    case capitalF = 70
    /// U+0071, 0x0047, 'G'.
    case capitalG
    /// U+0072, 0x0048, 'H'.
    case capitalH
    /// U+0073, 0x0049, 'I'.
    case capitalI
    /// U+0074, 0x004A, 'J'.
    case capitalJ
    /// U+0075, 0x004B, 'K'.
    case capitalK
    /// U+0076, 0x004C, 'L'.
    case capitalL
    /// U+0077, 0x004D, 'M'.
    case capitalM
    /// U+0078, 0x004E, 'N'.
    case capitalN
    /// U+0079, 0x004F, 'O'.
    case capitalO
    /// U+0080, 0x0050, 'P'.
    case capitalP = 80
    /// U+0081, 0x0051, 'Q'.
    case capitalQ
    /// U+0082, 0x0052, 'R'.
    case capitalR
    /// U+0083, 0x0053, 'S'.
    case capitalS
    /// U+0084, 0x0054, 'T'.
    case capitalT
    /// U+0085, 0x0055, 'U'.
    case capitalU
    /// U+0086, 0x0056, 'V'.
    case capitalV
    /// U+0087, 0x0057, 'W'.
    case capitalW
    /// U+0088, 0x0058, 'X'.
    case capitalX
    /// U+0089, 0x0059, 'Y'.
    case capitalY
    /// U+0090, 0x005A, 'Z'.
    case capitalZ = 90
    /// U+0091, 0x005B, '['.
    case leftSquareBracket
    /// U+0092, 0x005C, '\'.
    case reverseSolidus
    /// U+0093, 0x005D, ']'.
    case rightSquareBracket
    /// U+0094, 0x005E, '^'.
    case circumflexAccent
    /// U+0095, 0x005F, '_'.
    case lowLine
    /// U+0096, 0x0060, '`'.
    case graveAccent
    /// U+0097, 0x0061, 'a'.
    case smallA
    /// U+0098, 0x0062, 'b'.
    case smallB
    /// U+0099, 0x0063, 'c'.
    case smallC
    /// U+0100, 0x0064, 'd'.
    case smallD = 100
    /// U+0101, 0x0065, 'e'.
    case smallE
    /// U+0102, 0x0066, 'f'.
    case smallF
    /// U+0103, 0x0067, 'g'.
    case smallG
    /// U+0104, 0x0068, 'h'.
    case smallH
    /// U+0105, 0x0069, 'i'.
    case smallI
    /// U+0106, 0x006A, 'j'.
    case smallJ
    /// U+0107, 0x006B, 'k'.
    case smallK
    /// U+0108, 0x006C, 'l'.
    case smallL
    /// U+0109, 0x006D, 'm'.
    case smallM
    /// U+0110, 0x006E, 'n'.
    case smallN = 110
    /// U+0111, 0x006F, 'o'.
    case smallO
    /// U+0112, 0x0070, 'p'.
    case smallP
    /// U+0113, 0x0071, 'q'.
    case smallQ
    /// U+0114, 0x0072, 'r'.
    case smallR
    /// U+0115, 0x0073, 's'.
    case smallS
    /// U+0116, 0x0074, 't'.
    case smallT
    /// U+0117, 0x0075, 'u'.
    case smallU
    /// U+0118, 0x0076, 'v'.
    case smallV
    /// U+0119, 0x0077, 'w'.
    case smallW
    /// U+0120, 0x0078, 'x'.
    case smallX = 120
    /// U+0121, 0x0079, 'y'.
    case smallY
    /// U+0122, 0x007A, 'z'.
    case smallZ
    /// U+0123, 0x007B, '{'.
    case leftCurlyBracket
    /// U+0124, 0x007C, '|'.
    case verticalLine
    /// U+0125, 0x007D, '}'.
    case rightCurlyBracket
    /// U+0126, 0x007E, '~'.
    case tilde
    /// U+0127, 0x007F, not printable.
    case delete
    /// U+0128, 0x0080, not printable.
    case paddingCharacter
    /// U+0129, 0x0081, not printable.
    case highOctetPreset
    /// U+0130, 0x0082, not printable.
    case breakPermittedHere = 130
    /// U+0131, 0x0083, not printable.
    case noBreakHere
    /// U+0132, 0x0084, not printable.
    case index
    /// U+0133, 0x0085, not printable.
    case nextLine
    /// U+0134, 0x0086, not printable.
    case startOfSelectedArea
    /// U+0135, 0x0087, not printable.
    case endOfSelectedArea
    /// U+0136, 0x0088, not printable.
    case characterTabulationSet
    /// U+0137, 0x0089, not printable.
    case characterTabulationWithJustification
    /// U+0138, 0x008A, not printable.
    case lineTabulationSet
    /// U+0139, 0x008B, not printable.
    case partialLineForward
    /// U+0140, 0x008C, not printable.
    case partialLineBackward = 140
    /// U+0141, 0x008D, not printable.
    case reverseLineFeed
    /// U+0142, 0x008E, not printable.
    case singleShiftTwo
    /// U+0143, 0x008F, not printable.
    case singleShiftThree
    /// U+0144, 0x0090, not printable.
    case deviceControlString
    /// U+0145, 0x0091, not printable.
    case privateUseOne
    /// U+0146, 0x0092, not printable.
    case privateUseTwo
    /// U+0147, 0x0093, not printable.
    case setTransmitState
    /// U+0148, 0x0094, not printable.
    case cancelcharacter
    /// U+0149, 0x0095, not printable.
    case messageWaiting
    /// U+0150, 0x0096, not printable.
    case startOfProtectedArea = 150
    /// U+0151, 0x0097, not printable.
    case endOfProtectedArea
    /// U+0152, 0x0098, not printable.
    case startOfString
    /// U+0153, 0x0099, not printable.
    case singleGraphicCharacterIntroducer
    /// U+0154, 0x009A, not printable.
    case singleCharacterIntroducer
    /// U+0155, 0x009B, not printable.
    case controlSequenceIntroducer
    /// U+0156, 0x009C, not printable.
    case stringTerminator
    /// U+0157, 0x009D, not printable.
    case operatingSystemCommand
    /// U+0158, 0x009E, not printable.
    case privateMessage
    /// U+0159, 0x009F, not printable.
    case applicationProgramCommand
    /// U+0160, 0x00A0, not printable.
    case nonbreakingSpace = 160
    /// U+0161, 0x00A1, '¡'.
    case invertedExclamationMark
    /// U+0162, 0x00A2, '¢'.
    case centSign
    /// U+0163, 0x00A3, '£'.
    case poundSign
    /// U+0164, 0x00A4, '¤'.
    case currencySign
    /// U+0165, 0x00A5, '¥'.
    case yenSign
    /// U+0166, 0x00A6, '¦'.
    case brokenBar
    /// U+0167, 0x00A7, '§'.
    case sectionSign
    /// U+0168, 0x00A8, '¨'.
    case diaeresis
    /// U+0169, 0x00A9, '©'.
    case copyrightSign
    /// U+0170, 0x00AA, 'ª'.
    case feminineOrdinalIndicator = 170
    /// U+0171, 0x00AB, '«'.
    case leftDoubleAngleQuotes // TODO: name
    /// U+0172, 0x00AC, '¬'.
    case notSign
    /// U+0173, 0x00AD, not printable.
    case softHyphen
    /// U+0174, 0x00AE, '®'.
    case registeredSign
    /// U+0175, 0x00AF, '¯'.
    case macron
    /// U+0176, 0x00B0, '°'.
    case degreeSign
    /// U+0177, 0x00B1, '±'.
    case plusMinusSign
    /// U+0178, 0x00B2, '²'.
    case superscriptTwo
    /// U+0179, 0x00B3, '³'.
    case superscriptThree
    /// U+0180, 0x00B4, '´'.
    case acuteAccent = 180
    /// U+0181, 0x00B5, 'µ'.
    case microSign
    /// U+0182, 0x00B6, '¶'.
    case pilcrowSign
    /// U+0183, 0x00B7, '·'.
    case middleDot
    /// U+0184, 0x00B8, '¸'.
    case cedilla
    /// U+0185, 0x00B9, '¹'.
    case superscriptOne
    /// U+0186, 0x00BA, 'º'.
    case masculineOrdinalIndicator
    /// U+0187, 0x00BB, '»'.
    case rightDoubleAngleQuotes // TODO: name
    /// U+0188, 0x00BC, '¼'.
    case fractionOneQuarter
    /// U+0189, 0x00BD, '½'.
    case fractionOneHalf
    /// U+0190, 0x00BE, '¾'.
    case fractionThreeQuarters = 190
    /// U+0191, 0x00BF, '¿'.
    case invertedQuestionMark
    /// U+0192, 0x00C0, 'À'.
    case capitalAwithGrave
    /// U+0193, 0x00C1, 'Á'.
    case capitalAwithAcute
    /// U+0194, 0x00C2, 'Â'.
    case capitalAwithCircumflex
    /// U+0195, 0x00C3, 'Ã'.
    case capitalAwithTilde
    /// U+0196, 0x00C4, 'Ä'.
    case capitalAwithDiaeresis
    /// U+0197, 0x00C5, 'Å'.
    case capitalAwithRingAbove
    /// U+0198, 0x00C6, 'Æ'.
    case capitalAE
    /// U+0199, 0x00C7, 'Ç'.
    case capitalCwithCedilla
    /// U+0200, 0x00C8, 'È'.
    case capitalEwithGrave = 200
    /// U+0201, 0x00C9, 'É'.
    case capitalEwithAcute
    /// U+0202, 0x00CA, 'Ê'.
    case capitalEwithCircumflex
    /// U+0203, 0x00CB, 'Ë'.
    case capitalEwithDiaeresis
    /// U+0204, 0x00CC, 'Ì'.
    case capitalIwithGrave
    /// U+0205, 0x00CD, 'Í'.
    case capitalIwithAcute
    /// U+0206, 0x00CE, 'Î'.
    case capitalIwithCircumflex
    /// U+0207, 0x00CF, 'Ï'.
    case capitalIwithDiaeresis
    /// U+0208, 0x00D0, 'Ð'.
    case capitalEth
    /// U+0209, 0x00D1, 'Ñ'.
    case capitalNwithTilde
    /// U+0210, 0x00D2, 'Ò'.
    case capitalOwithGrave = 210
    /// U+0211, 0x00D3, 'Ó'.
    case capitalOwithAcute
    /// U+0212, 0x00D4, 'Ô'.
    case capitalOwithCircumflex
    /// U+0213, 0x00D5, 'Õ'.
    case capitalOwithTilde
    /// U+0214, 0x00D6, 'Ö'.
    case capitalOwithDiaeresis
    /// U+0215, 0x00D7, '×'.
    case multiplicationSign
    /// U+0216, 0x00D8, 'Ø'.
    case capitalOwithStroke
    /// U+0217, 0x00D9, 'Ù'.
    case capitalUwithGrave
    /// U+0218, 0x00DA, 'Ú'.
    case capitalUwithAcute
    /// U+0219, 0x00DB, 'Û'.
    case capitalUwithCircumflex
    /// U+0220, 0x00DC, 'Ü'.
    case capitalUwithDiaeresis = 220
    /// U+0221, 0x00DD, 'Ý'.
    case capitalYwithAcute
    /// U+0222, 0x00DE, 'Þ'.
    case capitalThorn
    /// U+0223, 0x00DF, 'ß'.
    case smallSharpS
    /// U+0224, 0x00E0, 'à'.
    case smallAwithGrave
    /// U+0225, 0x00E1, 'á'.
    case smallAwithAcute
    /// U+0226, 0x00E2, 'â'.
    case smallAwithCircumflex
    /// U+0227, 0x00E3, 'ã'.
    case smallAwithTilde
    /// U+0228, 0x00E4, 'ä'.
    case smallAwithDiaeresis
    /// U+0229, 0x00E5, 'å'.
    case smallAwithRingAbove
    /// U+0230, 0x00E6, 'æ'.
    case smallAe = 230
    /// U+0231, 0x00E7, 'ç'.
    case smallCwithCedilla
    /// U+0232, 0x00E8, 'è'.
    case smallEwithGrave
    /// U+0233, 0x00E9, 'é'.
    case smallEwithAcute
    /// U+0234, 0x00EA, 'ê'.
    case smallEwithCircumflex
    /// U+0235, 0x00EB, 'ë'.
    case smallEwithDiaeresis
    /// U+0236, 0x00EC, 'ì'.
    case smallIwithGrave
    /// U+0237, 0x00ED, 'í'.
    case smallIwithAcute
    /// U+0238, 0x00EE, 'î'.
    case smallIwithCircumflex
    /// U+0239, 0x00EF, 'ï'.
    case smallIwithDiaeresis
    /// U+0240, 0x00F0, 'ð'.
    case smallEth = 240
    /// U+0241, 0x00F1, 'ñ'.
    case smallNwithTilde
    /// U+0242, 0x00F2, 'ò'.
    case smallOwithGrave
    /// U+0243, 0x00F3, 'ó'.
    case smallOwithAcute
    /// U+0244, 0x00F4, 'ô'.
    case smallOwithCircumflex
    /// U+0245, 0x00F5, 'õ'.
    case smallOwithTilde
    /// U+0246, 0x00F6, 'ö'.
    case smallOwithDiaeresis
    /// U+0247, 0x00F7, '÷'.
    case divisionSign
    /// U+0248, 0x00F8, 'ø'.
    case smallOwithStroke
    /// U+0249, 0x00F9, 'ù'.
    case smallUwithGrave
    /// U+0250, 0x00FA, 'ú'.
    case smallUwithAcute = 250
    /// U+0251, 0x00FB, 'û'.
    case smallUwithCircumflex
    /// U+0252, 0x00FC, 'ü'.
    case smallUwithDiaeresis
    /// U+0253, 0x00FD, 'ý'.
    case smallYwithAcute
    /// U+0254, 0x00FE, 'þ'.
    case smallThorn
    /// U+0255, 0x00FF, 'ÿ'.
    case smallYwithDiaeresis = 255
    
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

    /// Checks if the value is an ASCII small character: U+0061 ‘a’ ... U+007A ‘z’.
    @inlinable
    @inline(__always)
    public func issmall() -> Bool {
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
