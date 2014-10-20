module io.dstream;

import std.stdio;
import std.bitmanip;
import std.conv;

/**
 * Similar to the Java Data I/O stream classes
 * Allows application to read / write primitive data types
 * to and from a stream.
 */
class DataStream
{
public:
    // doesn't close stream
    this(FILE* stream) {        
        _file = File.wrapFile(stream);
    }

    this(string filename, string mode) {
        _file.open(filename, mode);
    }

    void close() {
        _file.close();
    }

    ulong tell() const {
        return _file.tell();
    }

    int peek()
    {
        int c;

        FILE* fp = _file.getFP();

        c = fgetc(fp);
        ungetc(c, fp);

        return c;
    }

    ulong length() {
        ulong save = tell();
        
        seek(0L, SEEK_END);
        ulong sz = tell();

        seek(save);

        return sz;
    }

    uint skipBytes(uint n) {
        if (n == 0) {
            return 0;
        }

        ulong pos = tell();
        ulong len = length();
        ulong newpos = pos + n;
        if (newpos > len) {
            newpos = len;
        }
        seek(newpos);

        // return the actual number of bytes skipped
        return cast(uint) (newpos - pos);
    }

    bool eof() {
        return _file.eof() || peek() == -1;
    }

    ubyte[] read(ubyte[] buf) {
        return _file.rawRead(buf);
    }

    ushort readShort() {
        ubyte[ushort.sizeof] buffer;
        read(buffer);
        ushort result = bigEndianToNative!ushort(buffer);
        return result;
    }

    uint readInt() {
        ubyte[uint.sizeof] buffer;
        read(buffer);
        uint result = bigEndianToNative!uint(buffer);
        return result;
    }

    ulong readLong() {
        ubyte[ulong.sizeof] buffer;
        read(buffer);
        ulong result = bigEndianToNative!ulong(buffer);
        return result;
    }

    /**
    * Reads from the stream a representation
    * of a Unicode character string encoded in
    * modified UTF-8 format;
    */
    string readUTF() {
        ushort utflen = readShort();

        ubyte[] bytearr = new ubyte[utflen];
        wchar[] chararr = new wchar[utflen];

        ushort count = 0;
        ushort chararr_count = 0;
        
        _file.rawRead(bytearr);

        int c, char2, char3;
        while (count < utflen) {
            c = bytearr[count] & 0xff;
            if (c > 127) break;
            count++;
            chararr[chararr_count++] = cast(wchar)c;
        }

        while (count < utflen) {
            c = bytearr[count] & 0xff;
            switch (c >> 4) {
                case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
                    /* 0xxxxxxx*/
                    count++;
                    chararr[chararr_count++] = cast(wchar)c;
                    break;
                case 12: case 13:
                    /* 110x xxxx   10xx xxxx*/
                    count += 2;
                    if (count > utflen)
                        throw new Exception(
                            "malformed input: partial character at end");
                    char2 = cast(int) bytearr[count-1];
                    if ((char2 & 0xC0) != 0x80)
                        throw new Exception("malformed input");
                    chararr[chararr_count++] = cast(wchar)(((c & 0x1F) << 6) |
                        (char2 & 0x3F));
                    break;
                case 14:
                    /* 1110 xxxx  10xx xxxx  10xx xxxx */
                    count += 3;
                    if (count > utflen)
                        throw new Exception("malformed input: partial character at end");
                    char2 = cast(int) bytearr[count-2];
                    char3 = cast(int) bytearr[count-1];
                    if (((char2 & 0xC0) != 0x80) || ((char3 & 0xC0) != 0x80))
                        throw new Exception("malformed input");
                    chararr[chararr_count++] = cast(wchar)(((c & 0x0F) << 12) |
                                                    ((char2 & 0x3F) << 6)  |
                                                    ((char3 & 0x3F) << 0));
                    break;
                default:
                    /* 10xx xxxx,  1111 xxxx */
                    throw new Exception("malformed input");
            }
        }

        return to!string(chararr);
    }

    void seek(ulong pos, int origin = SEEK_SET) {
        _file.seek(pos, origin);
    }

    void writeBytes(ubyte[] bytes) {
        auto result = fwrite(bytes.ptr, ubyte.sizeof, bytes.length, _file.getFP());
        if (result != bytes.length)
            throw new Exception("cannot write to stream.");
    }

    void writeShort(short s) {
        auto bytes = nativeToBigEndian(s);
        writeBytes(cast(ubyte[])bytes);
    }

    void writeInt(int i) {
        auto bytes = nativeToBigEndian(i);
        writeBytes(cast(ubyte[])bytes);
    }

    void writeLong(long l) {
        auto bytes = nativeToBigEndian(l);
        writeBytes(cast(ubyte[])bytes);
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

        auto bytearr = new ubyte[utflen+2];
        auto lenbytes = nativeToBigEndian(cast(ushort)utflen);

        bytearr[count++] = lenbytes[0];
        bytearr[count++] = lenbytes[1];

        foreach(dchar c; str) {
            if ((c >= 0x0001) && (c <= 0x007F)) {
                bytearr[count++] = cast(ubyte) c;

            } else if (c > 0x07FF) {
                bytearr[count++] = cast(ubyte) (0xE0 | ((c >> 12) & 0x0F));
                bytearr[count++] = cast(ubyte) (0x80 | ((c >>  6) & 0x3F));
                bytearr[count++] = cast(ubyte) (0x80 | ((c >>  0) & 0x3F));
            } else {
                bytearr[count++] = cast(ubyte) (0xC0 | ((c >>  6) & 0x1F));
                bytearr[count++] = cast(ubyte) (0x80 | ((c >>  0) & 0x3F));
            }
        }

        writeBytes(bytearr);
    }

private:
    File _file;
}
