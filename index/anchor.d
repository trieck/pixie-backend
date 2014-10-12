module anchor;

/**
 * An anchor is a virtual term-location identifier in the document repository.
 * Each anchor is 8-bytes long. The bit-layout of an anchor is:
 * <p/>
 * -------------ANCHOR-------------
 * 63.....48 47........16 15......0
 * {FILENUM} {FILEOFFSET} {WORDNUM}
 * ---------DOCID--------|---------
 * <p/>
 * FILENUM 	    : file # in repository (16-bits, 32,767 max number of files)
 * FILEOFFSET	: offset into file where record is located (32-bits, max file size ~2GB)
 * WORDNUM	    : word number of term in field (16-bits, 32,767 max words per field)
 * DOCID        : The upper 48-bits of the anchor represents the document id.
 */
class Anchor 
{
public:
    enum { FILENUM_BITS = 16 }
    enum { OFFSET_BITS = 32 }
    enum { WORDNUM_BITS = 16 }

    this(ulong anchorID) {
        _anchorID = anchorID;
    }

    static ulong makeAnchorID(ushort filenum, uint offset, ushort wordnum) {

        assert (filenum < (1 << FILENUM_BITS) - 1);
        assert (offset < (cast(ulong) 1 << OFFSET_BITS) - 1);
        assert (wordnum < (1 << WORDNUM_BITS) - 1);

        ulong anchorid = (cast(ulong) (filenum & 0x7FFF) << (OFFSET_BITS + WORDNUM_BITS));
        anchorid |= (cast(ulong) offset & 0x7FFFFFFF) << WORDNUM_BITS;
        anchorid |= wordnum & 0x7FFF;

        return anchorid;
    }

    public ulong getAnchorID() {
        return _anchorID;
    }

    public ulong getDocID() {
        return (_anchorID >>> (WORDNUM_BITS)) & 0x7FFFFFFF;
    }

    public ushort getWordNum() {
        return (_anchorID & 0x7FFF);
    }

private:
    ulong _anchorID;
}