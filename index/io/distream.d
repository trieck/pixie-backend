module io.distream;

import std.stdio;
import std.bitmanip;
import std.conv;

/**
 * Inspired by the Java class of the same name.
 * Allows application to read primitive data types
 * from a stream.
 */
class DataInputStream
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

    int peek()
    {
        int c;

        FILE* fp = _file.getFP();

        c = fgetc(fp);
        ungetc(c, fp);

        return c;
    }

    bool eof() {
        return _file.eof() || peek() == -1;
    }

    ubyte[] read(ubyte[] buf) {
        return _file.rawRead(buf);
    }

    short readShort() {
        ubyte[2] buffer;
        read(buffer);
        ushort result = bigEndianToNative!ushort(buffer);
        return result;
    }

    uint readInt() {
        ubyte[4] buffer;
        read(buffer);
        uint result = bigEndianToNative!uint(buffer);
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

private:
    File _file;
}
