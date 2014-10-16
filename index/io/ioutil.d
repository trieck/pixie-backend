module io.ioutil;

import io.distream;
import io.dostream;
import std.algorithm : min;

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
    static void transfer(DataInputStream dis, DataOutputStream dos, int size) {
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
private:
    enum { BUF_SIZE = 16384 }
}