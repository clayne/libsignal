//
// Copyright 2023 Signal Messenger, LLC.
// SPDX-License-Identifier: AGPL-3.0-only
//

import ByteArray from '../internal/ByteArray';
import * as Native from '../../../Native';

export default class BackupAuthCredentialResponse extends ByteArray {
  private readonly __type?: never;

  constructor(contents: Uint8Array) {
    super(contents, Native.BackupAuthCredentialResponse_CheckValidContents);
  }
}
