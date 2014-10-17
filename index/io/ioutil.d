module io.ioutil;

import io.dstream;
import std.algorithm : min;
import std.array;

class IOUtil
{
public:
    /**
     * Transfer bytes from input stream to output stream
     *
     * @param dis,   the input stream
     * @param dos,   the output stream
     * @param size, the number of bytes to transfer
     */
    static void transfer(DataStream dis, DataStream dos, int size) {
        ubyte[] buf = new ubyte[BUF_SIZE];
        
        ubyte[] slice;
        int m;

        while (size > 0) {
            m = min(BUF_SIZE, size);
            
            slice = dis.read(buf[0..m]);
            if (slice.length != m)
                throw new Exception("unable to read from input stream.");
                
            dos.writeBytes(slice);

            size -= m;
        }        
    }

    /**
     * Write a continuous series of bytes to output stream
     * @param dos,  the output stream
     * @param size, the number of bytes to write
     * @param b,    the byte to write
     */
    static void fill(DataStream dos, long size, ubyte b) {
        ubyte[] buf = new ubyte[BUF_SIZE];

        foreach(by; buf)
            by = b;

        int m;
        while (size > 0) {
            m = cast(int) min(BUF_SIZE, size);
            dos.writeBytes(buf[0..m]);
            size -= m;
        }
    }

private:
    enum { BUF_SIZE = 16384 }
}