//
// Copyright 2023 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import Foundation
import LibSignalClient
import XCTest

class PinTests: TestCaseBase {
    func testBadSaltLength() {
        XCTAssertThrowsError(try PinHash(normalizedPin: Array("password".utf8), salt: [0xFF])) {
            guard case SignalError.invalidType(_) = $0 else {
                XCTFail("wrong error: \($0)")
                return
            }
        }
    }

    func testBadEncodedHash() {
        XCTAssertThrowsError(try verifyLocalPin(Array("password".utf8), againstEncodedHash: "not-a-hash")) {
            guard case SignalError.invalidArgument(_) = $0 else {
                XCTFail("wrong error: \($0)")
                return
            }
        }
    }

    func testVerify() {
        let pin = Array("password".utf8)
        let hash = try! hashLocalPin(pin)
        XCTAssertTrue(try! verifyLocalPin(pin, againstEncodedHash: hash))
        XCTAssertFalse(try! verifyLocalPin(Array("badpassword".utf8), againstEncodedHash: hash))
    }

    func testKnown() {
        let pin = Array("password".utf8)
        // echo "000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f" | xxd -r -p | base64
        let salt = Data(base64Encoded: "AAECAwQFBgcICQoLDA0ODxAREhMUFRYXGBkaGxwdHh8=")!

        let pinHash = try! PinHash(normalizedPin: pin, salt: salt)
        XCTAssertEqual(
            pinHash.accessKey,
            // echo "ab7e8499d21f80a6600b3b9ee349ac6d72c07e3359fe885a934ba7aa844429f8" | xxd -r -p | base64
            Data(base64Encoded: "q36EmdIfgKZgCzue40msbXLAfjNZ/ohak0unqoREKfg=")!
        )

        XCTAssertEqual(
            pinHash.encryptionKey,
            // echo "44652df80490fc66bb864a9e638b2f7dc9e20649671dd66bbb9c37bee2bfecf1" | xxd -r -p | base64
            Data(base64Encoded: "RGUt+ASQ/Ga7hkqeY4svfcniBklnHdZru5w3vuK/7PE=")!
        )
    }

    func testKnown2() {
        let pin = Array("anotherpassword".utf8)
        // echo "202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f" | xxd -r -p | base64
        let salt = Data(base64Encoded: "ICEiIyQlJicoKSorLC0uLzAxMjM0NTY3ODk6Ozw9Pj8=")!

        let pinHash = try! PinHash(normalizedPin: pin, salt: salt)
        XCTAssertEqual(
            pinHash.accessKey,
            // echo "301d9dd1e96f20ce51083f67d3298fd37b97525de8324d5e12ed2d407d3d927b" | xxd -r -p | base64
            Data(base64Encoded: "MB2d0elvIM5RCD9n0ymP03uXUl3oMk1eEu0tQH09kns=")!
        )

        XCTAssertEqual(
            pinHash.encryptionKey,
            // echo "b6f16aa0591732e339b7e99cdd5fd6586a1c285c9d66876947fd82f66ed99757" | xxd -r -p | base64
            Data(base64Encoded: "tvFqoFkXMuM5t+mc3V/WWGocKFydZodpR/2C9m7Zl1c=")!
        )
    }

    func testSvr2PinHash() throws {
        let pin = Array("password".utf8)
        let username = "username"

        let mrenclave = [UInt8](fromHexString: "38e01eff4fe357dc0b0e8ef7a44b4abc5489fbccba3a78780f3872c277f62bf3")!

        let knownSalt = [UInt8](fromHexString: "9898e82efa6cbf24c831da35b45c16748137f10fba9c0cb026d3b767281e8664")!

        let pinHash = try PinHash(normalizedPin: pin, username: username, mrenclave: mrenclave)

        let expectedHash = try PinHash(normalizedPin: pin, salt: knownSalt)

        XCTAssertEqual(pinHash.encryptionKey, expectedHash.encryptionKey)
        XCTAssertEqual(pinHash.accessKey, expectedHash.accessKey)
    }
}
