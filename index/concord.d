module concord;

import std.stdio : File;
import io.tempfile;
import inverter;

class Concordance
{
public:
    this() {
        _block = new Inverter;
        _tempfiles = [];
    }

    ~this() {
    }

    void insert(string term, ulong anchor) {

        if (isFull()) {
            blockSave();
        } 

        _block.insert(term, anchor);        
    }

    string merge() {
        blockSave();

        return "";
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
    }

    File[] _tempfiles; // temporary files
    Inverter _block;
}
