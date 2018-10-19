//
// Wire
// Copyright (C) 2016 Wire Swiss GmbH
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see http://www.gnu.org/licenses/.
//

extension CharacterSet {
    static let asciiPrintableSet = CharacterSet(charactersIn: "!\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~")
}

extension UInt32 {
    static let cancelTag: UInt32 = 0xE007F
}

extension Unicode.Scalar {
    static let cancelTag: Unicode.Scalar = Unicode.Scalar(UInt32.cancelTag)!

    var isEmojiComponentOrMiscSymbol: Bool {
        switch self.value {
        case 0x200D,       // Zero width joiner
        0x2139,            // the info symobol
        0x2030...0x2BFF,   // Misc symbols
        0x2600...0x27BF,   // Misc symbols, Dingbats
        UInt32.cancelTag,
        0xFE00...0xFE0F:   // Variation Selectors
            return true
        default:
            return false
        }
    }


    var isEmoji: Bool {
        //Unicode General Category S* contains Sc, Sk, Sm & So, we just interest on So(5855 items)
        return (CharacterSet.symbols.contains(self) && !CharacterSet.asciiPrintableSet.contains(self)) ||
            self.isEmojiComponentOrMiscSymbol
    }
    
}

extension String {
    public func existsIn(characterSet: CharacterSet) -> Bool {
        for char in self {
            for scalar in char.unicodeScalars {
                if characterSet.contains(scalar) {
                    return true
                }
            }
        }
        return false
    }

    public var containsEmoji: Bool {
        guard count > 0 else { return false }

        for char in self {
            for scalar in char.unicodeScalars {
                if scalar.isEmoji {
                    return true
                }
            }
        }

        return false
    }

    public var containsOnlyEmojiWithSpaces: Bool {
        return components(separatedBy: .whitespaces).joined().containsOnlyEmoji
    }

    var containsOnlyEmoji: Bool {
        guard count > 0 else { return false }

        let cancelTag = Unicode.Scalar.cancelTag

        for char in self {
            // some national flags are combination of black flag and characters, and ends with Cancel Tag
            if char.unicodeScalars.contains(cancelTag) {
                continue
            }

            for scalar in char.unicodeScalars {
                if !scalar.isEmoji {
                    return false
                }
            }
        }

        return true
    }
}
