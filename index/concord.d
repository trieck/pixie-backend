module concord;

import inverter;

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

private:
    bool isFull() {
        return _block.isFull();
    }

    void blockSave() {
    }

    string[] _tempfiles; // temporary files
    Inverter _block;
}
