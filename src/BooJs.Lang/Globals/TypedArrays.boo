# Ref: http://www.khronos.org/registry/typedarray/specs/latest/


namespace BooJs.Lang.Globals


class ArrayBuffer:
    byteLength as uint:
        get: pass

    def constructor(length as uint):
        pass
    def slice(begin as int) as ArrayBuffer:
        pass
    def slice(begin as int, end as int) as ArrayBuffer:
        pass

interface ArrayBufferView:
    buffer as ArrayBuffer:
        get
    byteLength as uint:
        get
    byteOffset as uint:
        get

class TypedArray(ArrayBufferView):
    static public final BYTES_PER_ELEMENT = 0

    length as uint:
        get: pass

    self[index as uint] as object:
        get: pass
        set: pass

    def constructor():
        pass
    def constructor(length as uint):
        pass
    def constructor(arr as TypedArray):
        pass
    def constructor(arr as (object)):
        pass
    def constructor(buffer as ArrayBuffer):
        pass
    def constructor(buffer as ArrayBuffer, byteOffset as uint):
        pass
    def constructor(buffer as ArrayBuffer, byteOffset as uint, length as uint):
        pass

    def @set(arr as TypedArray):
        pass
    def @set(arr as TypedArray, offset as uint):
        pass
    def @set(arr as (object)):
        pass
    def @set(arr as (object), offset as uint):
        pass
    def subarray(begin as int) as TypedArray:
        pass
    def subarray(begin as int, end as int) as TypedArray:
        pass


class Int8Array(TypedArray):
    pass

class Uint8Array(TypedArray):
    pass

class Uint8ClampedArray(Uint8Array):
    pass

class Int16Array(TypedArray):
    pass

class Uint16Array(TypedArray):
    pass

class Int32Array(TypedArray):
    pass

class Uint32Array(TypedArray):
    pass

class Float32Array(TypedArray):
    pass

class Float64Array(TypedArray):
    pass


class DataView(ArrayBufferView):
    def constructor(buffer as ArrayBuffer):
        pass
    def constructor(buffer as ArrayBuffer, offset as uint):
        pass
    def constructor(buffer as ArrayBuffer, offset as uint, length as uint):
        pass

    def getInt8(ofs as uint) as int:
        pass
    def getUint8(ofs as uint) as uint:
        pass
    def getInt16(ofs as uint) as int:
        pass
    def getInt16(ofs as uint, littleEndian as bool) as int:
        pass
    def getUint16(ofs as uint) as uint:
        pass
    def getUint16(ofs as uint, littleEndian as bool) as uint:
        pass
    def getInt32(ofs as uint) as int:
        pass
    def getInt32(ofs as uint, littleEndian as bool) as int:
        pass
    def getUint32(ofs as uint) as uint:
        pass
    def getUint32(ofs as uint, littleEndian as bool) as uint:
        pass
    def getFloat32(ofs as uint) as double:
        pass
    def getFloat32(ofs as uint, littleEndian as bool) as double:
        pass
    def getFloat64(ofs as uint) as double:
        pass
    def getFloat64(ofs as uint, littleEndian as bool) as double:
        pass

    def setInt8(ofs as uint, v as int):
        pass
    def setUint8(ofs as uint, v as uint):
        pass
    def setInt16(ofs as uint, v as int):
        pass
    def setInt16(ofs as uint, v as int, littleEndian as bool):
        pass
    def setUint16(ofs as uint, v as uint):
        pass
    def setUint16(ofs as uint, v as uint, littleEndian as bool):
        pass
    def setInt32(ofs as uint, v as int):
        pass
    def setInt32(ofs as uint, v as int, littleEndian as bool):
        pass
    def setUint32(ofs as uint, v as uint):
        pass
    def setUint32(ofs as uint, v as uint, littleEndian as bool):
        pass
    def setFloat32(ofs as uint, v as double):
        pass
    def setFloat32(ofs as uint, v as double, littleEndian as bool):
        pass
    def setFloat64(ofs as uint, v as double):
        pass
    def setFloat64(ofs as uint, v as double, littleEndian as bool):
        pass
