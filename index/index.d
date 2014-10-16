module index;

import std.file;
import io.distream;
import io.dostream;
import io.ioutil;
import concord;
import repos;
import indexfields;

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

    void write(string db, string[] fields) {
        // merge concordance blocks
        string concordFile = _concord.merge();

        auto outfile = _repos.getIndexPath(db);
        if (exists(outfile))
            remove(outfile);

        DataInputStream dis = new DataInputStream(concordFile, "rb");
        DataOutputStream dos = new DataOutputStream(outfile, "wb+");

        // write file magic number
        dos.writeInt(MAGIC_NO);

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
    }

private:
    enum { MAGIC_NO = 0xc001d00d }  // file magic number
    Repository _repos;               // content repository
    Concordance _concord;            // term concordance    
}
