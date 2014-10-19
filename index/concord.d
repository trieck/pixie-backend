module concord;

import std.stdio;
import inverter;
import concmerge;
import io.tempfile;

class Concordance
{
public:
    this() {
        _block = new Inverter;
        _tempfiles = [];
    }

    void insert(string term, ulong anchor) {

        if (isFull()) {
            blockSave();
        } 

        _block.insert(term, anchor);
    }

    File merge() {
        blockSave();

        if (_tempfiles.length == 1)
            return _tempfiles[0];   // optimization

        ConcordMerge merger = new ConcordMerge();
        return merger.merge(_tempfiles);
    }

private:
    bool isFull() {
        return _block.isFull();
    }

    void blockSave() {
        if (_block.getCount() == 0) {
            return;
        }

        File file = Tempfile.create("conc", "dat");
        _tempfiles ~= file;
        _block.write(file.getFP());
        file.close();
    }

    File[] _tempfiles; // temporary files
    Inverter _block;
}
