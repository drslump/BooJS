namespace BooJs.Compiler.SourceMap

class Base64VLQ:
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
    private static final VLQ_BASE_SHIFT = 5
    private static final VLQ_BASE = 1 << VLQ_BASE_SHIFT

    # A mask of bits for a VLQ digit (11111), 31 decimal.
    private static final VLQ_BASE_MASK = VLQ_BASE - 1

    # The continuation bit is the 6th bit.
    private static final VLQ_CONTINUATION_BIT = VLQ_BASE

    # Mapping of VLQ digits to characters
    private static final CHARMAP = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'


    private static def toSigned(value as int):
    """ Converts from a two-complement value to a value where the sign bit is
        is placed in the least significant bit. For example, as decimals:
        1 becomes 2 (10 binary), -1 becomes 3 (11 binary)
        2 becomes 4 (100 binary), -2 becomes 5 (101 binary)
    """
        if value <= 0:
            return ((-value) << 1) + 1
        else:
            return (value << 1) + 0


    static def encode(value as int) as string:
    """ Returns the base 64 VLQ encoded value """
        #return CHARMAP[0].ToString() if not value
        encoded = ""
        value = toSigned(value)
        while value > 0:
            digit = value & VLQ_BASE_MASK
            # Cast to unsigned to emulate zero-fill shift ( >>> )
            value = (value cast uint) >> VLQ_BASE_SHIFT
            if value > 0:
                digit |= VLQ_CONTINUATION_BIT

            assert digit >= 0 and digit < CHARMAP.Length
            encoded += CHARMAP[digit]
        return encoded
