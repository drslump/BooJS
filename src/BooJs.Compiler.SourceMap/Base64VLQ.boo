namespace BooJs.Compiler.SourceMap


static class Base64VLQ:
"""
 From: https://github.com/mozilla/source-map/blob/master/lib/source-map/base64-vlq.js

 A single base 64 digit can contain 6 bits of data. For the base 64 variable
 length quantities we use in the source map spec, the first bit is the sign,
 the next four bits are the actual value, and the 6th bit is the
 continuation bit. The continuation bit tells us whether there are more
 digits in this value following this digit.

 Continuation
 | Sign
 | |
 V V
 101011
"""
    # A Base64 VLQ digit can represent 5 bits, so it is base-32.
    final VLQ_BASE_SHIFT = 5
    final VLQ_BASE = 1 << VLQ_BASE_SHIFT

    # A mask of bits for a VLQ digit (11111), 31 decimal.
    final VLQ_BASE_MASK = VLQ_BASE - 1

    # The continuation bit is the 6th bit.
    final VLQ_CONTINUATION_BIT = VLQ_BASE

    # Mapping of VLQ digits to characters
    final CHARMAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    
    def encode(v as int) as string:
    """ Returns the base 64 VLQ encoded value """
        # Convert from a two-complement value to a value where the sign bit is
        # placed in the least significant bit.
        if v <= 0:
            v = ((-v) << 1) + 1
        else:
            v = v << 1
        
        encoded = ""
        while v > 0:
            digit = v & VLQ_BASE_MASK
            # Cast to unsigned to emulate zero-fill shift ( >>> )
            v = (v cast uint) >> VLQ_BASE_SHIFT
            
            digit |= VLQ_CONTINUATION_BIT if v > 0
            assert digit >= 0 and digit < CHARMAP.Length
            encoded += CHARMAP[digit]
            
        return encoded
