module index;

import std.file;
import std.stdio : File;
import io.dstream;
import io.ioutil;
import concord;
import content.defs;
import content.repos;
import indexfields;
import util.prime;
import util.dhash64;

class Index
{
public:
    this() {
        _concord = new Concordance;
        _repos = Repository.instance();
    }

    void insert(string term, ulong anchor) {
        _concord.insert(term, anchor);
    }

    public static ulong hash(string term, ulong size) {
        return (DoubleHash64.hash(term) & 0x7FFFFFFFFFFFFFFFL) % size;
    }

    void write(string db, string[] fields) {
        // merge concordance blocks
        File concordFile = _concord.merge();

        auto outfile = _repos.getIndexPath(db);

        DataStream dis = new DataStream(concordFile.name, "rb");
        DataStream dos = new DataStream(outfile, "wb+");

        // write file magic number
        dos.writeInt(INDEX_MAGIC_NO);

        // write the number of index fields
        dos.writeInt(cast(int) fields.length);

        // write index fields
        foreach(field; fields) {
            dos.writeUTF(field);
        }

        // write the total number of terms
        ulong term_count_offset = dos.tell();
        dos.writeInt(0); // not yet known

        // write the size of the hash table
        ulong hash_table_size_offset = dos.tell();
        dos.writeLong(0); // not yet known

        // write the offset to the hash table
        ulong hash_table_offset = dos.tell();
        dos.writeLong(0); // not yet known

        // concordance offset
        ulong concord_offset = dos.tell();

        // write terms & anchors
        uint n, nterms;
        string term;

        for (n = 0; !dis.eof(); ++nterms) {
            term = dis.readUTF();

            // read the anchor list size
            n = dis.readInt();

            // write the term
            dos.writeUTF(term);

            // write the anchor list size
            dos.writeInt(n);

            // transfer the anchor list
            IOUtil.transfer(dis, dos, n * cast(uint)ulong.sizeof);
        }

        dis.close();

        // generate the hash table

        // hash table location
        ulong hash_table_area = dos.tell();

        // write the total term count
        dos.seek(term_count_offset);
        dos.writeInt(nterms);

        // compute the size of the hash table and store it
        ulong tableSize = Prime.prime(nterms);
        dos.seek(hash_table_size_offset);
        dos.writeLong(tableSize);

        // write the offset to the hash table
        dos.seek(hash_table_offset);
        dos.writeLong(hash_table_area);
        dos.seek(hash_table_area); // jump back
        
        // need to ensure the hash table is empty
        IOUtil.fill(dos, tableSize * ulong.sizeof, 0);

        // we need two file pointers to the output file
        // in order to generate the hash table
        dis = new DataStream(outfile, "rb");

        // seek to the concordance
        dis.seek(concord_offset);

        ulong h, offset, term_offset = concord_offset;
        uint vsize;

        for (uint i = 0; i < nterms; i++) {
            term = dis.readUTF();

            h = hash(term, tableSize);

            // collisions are resolved via linear-probing
            for (; ; ) {
                offset = hash_table_area + (h * ulong.sizeof);

                dos.seek(offset);
                if (dos.readLong() == 0UL) {
                    break;
                }

                h = (h + 1) % tableSize;
            }

            dos.seek(offset);
            dos.writeLong(term_offset);

            // anchor list size
            vsize = cast(uint)(dis.readInt() * ulong.sizeof);
            dis.skipBytes(vsize);

            // next term offset
            term_offset = dis.tell();
        }

        dis.close();
        dos.close();
    }

private:
    Repository _repos;               // content repository
    Concordance _concord;            // term concordance    
}
