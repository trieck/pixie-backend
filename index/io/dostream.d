module io.dostream;

import std.stdio;
import std.bitmanip;

/*
 * Inspired by the Java class of the same name.
 * Allows application to write primitive data types
 * to a stream and use a data input stream to read the data read back in.
 * We do not rely on std.stream here to produce and consume data
 * created by the Java implementation.
 */
class DataOutputStream
{
public:
    this(FILE* stream) {
        _stream = stream;
    }

    void writeBytes(byte[] bytes) {
        auto result = fwrite(bytes.ptr, byte.sizeof, bytes.length, _stream);
        if (result != bytes.length)
            throw new Exception("cannot write to stream.");
    }

    void writeShort(short s) {
        auto bytes = nativeToBigEndian(s);
        writeBytes(cast(byte[])bytes);
    }

    void writeInt(int i) {
        auto bytes = nativeToBigEndian(i);
        writeBytes(cast(byte[])bytes);
    }

    void writeLong(long l) {
        auto bytes = nativeToBigEndian(l);
        writeBytes(cast(byte[])bytes);
    }

    /**
     * Writes a string to the stream using
     * modified UTF-8 encoding in a machine independent manner.
     *
     * First, two bytes are written to the stream as if by the 
     * writeShort method giving the number bytes to follow.
     * This value is the number of bytes actually written out,
     * not the length of the string.  Following the length, each
     * character of the string is output, in sequence, using the
     * modified UTF-8 encoding for the character.
     */
    void writeUTF(string str) {
        size_t strlen = str.length;
        size_t utflen = 0;
        size_t count = 0;

        foreach(dchar c; str) {
            if ((c >= 0x0001) && (c <= 0x007F)) {
                utflen++;
            } else if (c > 0x07FF) {
                utflen += 3;
            } else {
                utflen += 2;
            }
        }

        if (utflen > 65535)
            throw new Exception("encoded string too long.");

        auto bytearr = new byte[utflen+2];
        auto lenbytes = nativeToBigEndian(cast(ushort)utflen);

        bytearr[count++] = lenbytes[0];
        bytearr[count++] = lenbytes[1];

        foreach(dchar c; str) {
            if ((c >= 0x0001) && (c <= 0x007F)) {
                bytearr[count++] = cast(byte) c;

            } else if (c > 0x07FF) {
                bytearr[count++] = cast(byte) (0xE0 | ((c >> 12) & 0x0F));
                bytearr[count++] = cast(byte) (0x80 | ((c >>  6) & 0x3F));
                bytearr[count++] = cast(byte) (0x80 | ((c >>  0) & 0x3F));
            } else {
                bytearr[count++] = cast(byte) (0xC0 | ((c >>  6) & 0x1F));
                bytearr[count++] = cast(byte) (0x80 | ((c >>  0) & 0x3F));
            }
        }

        writeBytes(bytearr);
    }



private:
    FILE* _stream;
}