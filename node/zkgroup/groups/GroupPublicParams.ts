import ByteArray from '../internal/ByteArray';
import NativeImpl from '../../NativeImpl';
import GroupIdentifier from './GroupIdentifier';


export default class GroupPublicParams extends ByteArray {

  static SIZE = 97;

  constructor(contents: Buffer) {
    super(contents, GroupPublicParams.SIZE, true);
    NativeImpl.GroupPublicParams_CheckValidContents(contents);
  }

  getGroupIdentifier(): GroupIdentifier {
    return new GroupIdentifier(NativeImpl.GroupPublicParams_GetGroupIdentifier(this.contents));
  }

}
