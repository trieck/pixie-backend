module anchor;

/**
 * An anchor is a virtual term-location identifier in the document repository.
 * Each anchor is 8-bytes long. The bit-layout of an anchor is:
 * <p/>
 * ------------------ANCHOR------------------
 * 63......56 55....26 25.......16 15.......0
 * {FILE_NUM} {OFFSET} {FIELD_NUM} {WORD_NUM}
 * -------DOCID-------|
 * <p/>
 * FILE_NUM     : file # in repository (8-bits, 256 max number of files)
 * OFFSET       : offset into file where record is located (30-bits, max file size ~1GB)
 * FIELD_NUM    : field # in record (10-bits, 1,024 max top-level fields per record)
 * WORD_NUM     : word # of term in field (16-bits, 65,535 max words per field)
 * {DOC_ID}     : The upper 38-bits of the anchor represents the document id.
 */
class Anchor 
{
public:
    enum { FILENUM_BITS = 8 }
    enum { OFFSET_BITS = 30 }
    enum { FIELDNUM_BITS = 10 }
    enum { WORDNUM_BITS = 16 }

    this(ulong anchorID) {
        _anchorID = anchorID;
    }

    static ulong makeAnchorID(ubyte filenum, uint offset, ushort fieldnum, ushort wordnum) {
        assert (offset < (1 << OFFSET_BITS));
        assert (fieldnum < (1 << FIELDNUM_BITS));
        
        ulong anchorid = (cast(ulong) filenum << (OFFSET_BITS + FIELDNUM_BITS + WORDNUM_BITS));
        anchorid |= (cast(ulong)offset & 0x3FFFFFFF) << (FIELDNUM_BITS + WORDNUM_BITS);
        anchorid |= (fieldnum & 0x3FF) << WORDNUM_BITS;
        anchorid |= wordnum;

        return anchorid;
    }

    public ulong getAnchorID() const {
        return _anchorID;
    }

    public ulong getDocID() const {
        return (_anchorID >>> (FIELDNUM_BITS + WORDNUM_BITS));
    }

    override int opCmp(Object rhs) const {
        if (this is rhs)
            return 0;

        auto that = cast(Anchor)rhs;
        if (!that) return 1;

        if (getDocID() < that.getDocID())
            return int.min;

        if (getDocID() > that.getDocID())
            return int.max;

        return cast(int)(_anchorID - that._anchorID);
    }
private:
    ulong _anchorID;
}