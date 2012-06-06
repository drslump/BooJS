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
    VLQ_BASE_SHIFT = 5

    # binary: 100000
    VLQ_BASE = 1 << VLQ_BASE_SHIFT

    # binary: 011111
    VLQ_BASE_MASK = VLQ_BASE - 1

    # binary: 100000
    VLQ_CONTINUATION_BIT = VLQ_BASE

    def toSigned(value as int):
    """ Converts from a two-complement value to a value where the sign bit is
        is placed in the least significant bit. For example, as decimals:
        1 becomes 2 (10 binary), -1 becomes 3 (11 binary)
        2 becomes 4 (100 binary), -2 becomes 5 (101 binary)
    """
        if value < 0:
            return ((-value) << 1) + 1
        else:
            return value << 1

    def fromSigned(value as int):
    """ Converts to a two-complement value from a value where the sign bit is
        is placed in the least significant bit. For example, as decimals:
        2 (10 binary) becomes 1, 3 (11 binary) becomes -1
        4 (100 binary) becomes 2, 5 (101 binary) becomes -2
    """
        isNegative = (value & 1) == 1
        shifted = value >> 1
        return (-shifted if isNegative else shifted)

    def encode(value as int):
    """ Returns the base 64 VLQ encoded value """

        encoded = ""
        digit = 0
        vlq as uint = toSigned(value)

        while vlq > 0:
            digit = vlq & VLQ_BASE_MASK
            #vlq >>>= VLQ_BASE_SHIFT  # No zero-fill right shift in Boo/CLI
            vlq = vlq >> VLQ_BASE_SHIFT

            if vlq > 0:
                // There are still more digits in this value, so we must make sure the
                // continuation bit is marked.
                digit |= VLQ_CONTINUATION_BIT;

            encoded += base64(digit)

    def base64(digit):
        # TODO: Make this static
        intmap = {}
        idx = 0
        chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'.Split()
        for ch in chars:
            intmap[idx] = ch
            idx++

        return intmap[digit]
