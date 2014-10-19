module concmerge;

import std.stdio: File;
import std.file: remove;
import std.algorithm : min, cmp;
import concrecord;
import io.dstream;
import io.tempfile;
import io.ioutil;

class ConcordMerge
{
public:
     this() {
        _records = new ConcordRecord[NWAY+1];
     }

     File merge(File[] files)
     {
         _pass = countPasses(cast(uint)files.length);
         return mergeMany(files, 0, cast(uint)files.length);
     }

private:
    uint countPasses(uint argc) {
        uint i = 0;

        if (argc <= NWAY) {
            return 1;
        }

        while (argc > 0) {
            i++;
            argc -= min(argc, NWAY);
        }

        return i + countPasses(i);
    }

    File mergeMany(File[] files, uint offset, uint argc) {
         if (argc <= NWAY) {
             return mergeOnce(files, offset, argc);
         }

         File[] outfiles = [];

         uint i, n;
         for (i = 0; argc > 0; offset += n, argc -= n, i++) {
             n = min(argc, NWAY);
             outfiles ~= mergeOnce(files, offset, n);
         }

         return mergeMany(outfiles, 0, i);
    }

    File mergeOnce(File[] files, uint offset, uint argc) {
        _pass--;

        File file = Tempfile.create("conc", "dat");

        _out = new DataStream(file.name, "wb");

        immutable uint save = offset;    // remember the offset
        
        ConcordRecord[] recs = new ConcordRecord[argc + 1];

        uint i, j;
        for (i = 0; i < argc; i++, offset++) {
            recs[i] = new ConcordRecord;
            recs[i].stream = new DataStream(files[offset].name, "rb");
        }

        recs[argc] = null;

        ConcordRecord[] list = recs;
        
        while (read(list)) {
            list = least(recs);
            write(list);
        }

        File infile;
        for (i = 0, j = save; i < argc; i++, j++) {
            recs[i].stream.close();
            recs[i].stream = null;
            files[j].close();
            remove(files[j].name);
        }

        _out.close();
        _out = null;

        return file;
    }

    bool read(ConcordRecord[] recs) {
        for (uint i = 0; recs[i] !is null; i++) {
            if (recs[i].term == TERM_EOF) {
                return false;
            }

            // read term
            if (recs[i].stream.eof()) {    // EOF
                recs[i].term = TERM_EOF;
                recs[i].size = 0;
                continue;
            }

            recs[i].term = recs[i].stream.readUTF();

            // read size of anchor list
            recs[i].size = recs[i].stream.readInt();
        }

        return true;
    }

    ConcordRecord[] least(ConcordRecord[] recs) {
        uint j = 0, k = 0;
        int c;

        for (uint i = 0; recs[i] !is null; i++) {
            c = recs[i].term.cmp(recs[k].term);
            if (c < 0) {    // less than
                k = i;
                j = 0;
                _records[j++] = recs[i];
            } else if (c == 0) {    // equal to
                _records[j++] = recs[i];
            }
        }

        _records[j] = null;

        return _records;
    }

    void write(ConcordRecord[] recs) {
        if (recs[0].term !is null && recs[0].term == TERM_EOF) {
            return;
        }

        _out.writeUTF(recs[0].term);

        uint i, size = 0;
        for (i = 0; recs[i] !is null; i++) {
            size += recs[i].size;
        }

        // write anchor list size
        _out.writeInt(size);

        for (i = 0; recs[i] !is null; i++) {
            IOUtil.transfer(recs[i].stream, _out, cast(int)(recs[i].size * ulong.sizeof));
        }
    }

    ConcordRecord[] _records;                           // concordance records for least
    enum { NWAY = 100 }                                 // number of ways to merge
    enum : immutable(string) { TERM_EOF = "\uFFFD" };   // EOF indicator
    DataStream _out;                                    // output stream for merge;
    uint _pass;                                         // countdown of pass number
 }