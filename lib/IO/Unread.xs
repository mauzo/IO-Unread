#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

MODULE = IO::Unread	PACKAGE = IO::Unread

PROTOTYPES: DISABLE

ssize_t 
_unread (rfh, str)
    SV *rfh
    SV *str
CODE:
    {
        struct io *fh;
        PerlIO    *pio;
        char      *pv;
        STRLEN     len;

        if(!rfh || SVt_RV != SvTYPE(rfh))
            croak("First arg to IO::Unread::_unread must be a ref");

        fh = GvIO(SvRV(rfh));
        if(!fh || SVt_PVIO != SvTYPE(fh))
            croak("First arg to IO::Unread::_unread must be an IO ref");

        pio = IoIFP(fh);
        if(!pio)
	    croak("First arg to IO::Unread::_unread must be open for reading");

        if(!str || !(pv = SvPV(str, len)))
            croak("Second are to IO::Unread::_unread must be a string");

        RETVAL = PerlIO_unread(pio, pv, len);
    }
OUTPUT:
    RETVAL

