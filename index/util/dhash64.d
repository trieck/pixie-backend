module util.dhash64;

import std.outbuffer;
import std.bitmanip;
import util.hash64;

class DoubleHash64 {
public:
    static long hash(string s) {
        OutBuffer buffer = new OutBuffer;
        buffer.write(s);
        byte[] bytes = cast(byte[])buffer.toBytes();

        long h = Hash64.hash(bytes);

        buffer.data.length = buffer.offset = 0;

        byte[] buf = cast(byte[])nativeToLittleEndian(h);

        h = Hash64.hash(buf);

        return h;
    }
}