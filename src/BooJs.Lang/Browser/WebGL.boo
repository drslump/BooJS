# WebGL
#
# ref: http://www.khronos.org/registry/webgl/specs/latest/

namespace BooJs.Lang.Browser

import BooJs.Lang.Globals
import BooJs.Lang.Browser.Dom2(Element)


interface WebGLObject:
    pass

interface WebGLBuffer(WebGLObject):
    pass

interface WebGLFramebuffer(WebGLObject):
    pass

interface WebGLProgram(WebGLObject):
    pass

interface WebGLRenderbuffer(WebGLObject):
    pass

interface WebGLShader(WebGLObject):
    pass

interface WebGLTexture(WebGLObject):
    pass

interface WebGLUniformLocation:
    pass

interface WebGLActiveInfo:
    size as int:
        get
    type as int:
        get
    name as string:
        get

interface WebGLShaderPrecisionFormat:
    rangeMin as int:
        get
    rangeMax as int:
        get
    precision as int:
        get

interface WebGLContextAttributes:
    alpha as bool:
        get
    depth as bool:
        get
    stencil as bool:
        get
    antialias as bool:
        get
    premultipliedAlpha as bool:
        get
    preserveDrawingBuffer as bool:
        get

interface WebGLRenderingContext:
    # ClearBufferMask
    DEPTH_BUFFER_BIT as int:
        get
    STENCIL_BUFFER_BIT as int:
        get
    COLOR_BUFFER_BIT as int:
        get

    # BeginMode
    POINTS as int:
        get
    LINES as int:
        get
    LINE_LOOP as int:
        get
    LINE_STRIP as int:
        get
    TRIANGLES as int:
        get
    TRIANGLE_STRIP as int:
        get
    TRIANGLE_FAN as int:
        get

    # AlphaFunction (not supported in ES20)
    # NEVER
    # LESS
    # EQUAL
    # LEQUAL
    # GREATER
    # NOTEQUAL
    # GEQUAL
    # ALWAYS

   # BlendingFactorDest
    ZERO as int:
        get
    ONE as int:
        get
    SRC_COLOR as int:
        get
    ONE_MINUS_SRC_COLOR as int:
        get
    SRC_ALPHA as int:
        get
    ONE_MINUS_SRC_ALPHA as int:
        get
    DST_ALPHA as int:
        get
    ONE_MINUS_DST_ALPHA as int:
        get

    # BlendingFactorSrc
    # ZERO
    # ONE
    DST_COLOR as int:
        get
    ONE_MINUS_DST_COLOR as int:
        get
    SRC_ALPHA_SATURATE as int:
        get
    # SRC_ALPHA
    # ONE_MINUS_SRC_ALPHA
    # DST_ALPHA
    # ONE_MINUS_DST_ALPHA

    # BlendEquationSeparate
    FUNC_ADD as int:
        get
    BLEND_EQUATION as int:
        get
    BLEND_EQUATION_RGB as int:
        get
    BLEND_EQUATION_ALPHA as int:
        get

    # BlendSubtract
    FUNC_SUBTRACT as int:
        get
    FUNC_REVERSE_SUBTRACT as int:
        get

       # Separate Blend Functions
    BLEND_DST_RGB as int:
        get
    BLEND_SRC_RGB as int:
        get
    BLEND_DST_ALPHA as int:
        get
    BLEND_SRC_ALPHA as int:
        get
    CONSTANT_COLOR as int:
        get
    ONE_MINUS_CONSTANT_COLOR as int:
        get
    CONSTANT_ALPHA as int:
        get
    ONE_MINUS_CONSTANT_ALPHA as int:
        get
    BLEND_COLOR as int:
        get

    # Buffer Objects
    ARRAY_BUFFER as int:
        get
    ELEMENT_ARRAY_BUFFER as int:
        get
    ARRAY_BUFFER_BINDING as int:
        get
    ELEMENT_ARRAY_BUFFER_BINDING as int:
        get

    STREAM_DRAW as int:
        get
    STATIC_DRAW as int:
        get
    DYNAMIC_DRAW as int:
        get

    BUFFER_SIZE as int:
        get
    BUFFER_USAGE as int:
        get

    CURRENT_VERTEX_ATTRIB as int:
        get

    # CullFaceMode
    FRONT as int:
        get
    BACK as int:
        get
    FRONT_AND_BACK as int:
        get

    # DepthFunction
    # NEVER
    # LESS
    # EQUAL
    # LEQUAL
    # GREATER
    # NOTEQUAL
    # GEQUAL
    # ALWAYS

    # EnableCap
    # TEXTURE_2D
    CULL_FACE as int:
        get
    BLEND as int:
        get
    DITHER as int:
        get
    STENCIL_TEST as int:
        get
    DEPTH_TEST as int:
        get
    SCISSOR_TEST as int:
        get
    POLYGON_OFFSET_FILL as int:
        get
    SAMPLE_ALPHA_TO_COVERAGE as int:
        get
    SAMPLE_COVERAGE as int:
        get

    # ErrorCode
    NO_ERROR as int:
        get
    INVALID_ENUM as int:
        get
    INVALID_VALUE as int:
        get
    INVALID_OPERATION as int:
        get
    OUT_OF_MEMORY as int:
        get

    # FrontFaceDirection
    CW as int:
        get
    CCW as int:
        get

    # GetPName
    LINE_WIDTH as int:
        get
    ALIASED_POINT_SIZE_RANGE as int:
        get
    ALIASED_LINE_WIDTH_RANGE as int:
        get
    CULL_FACE_MODE as int:
        get
    FRONT_FACE as int:
        get
    DEPTH_RANGE as int:
        get
    DEPTH_WRITEMASK as int:
        get
    DEPTH_CLEAR_VALUE as int:
        get
    DEPTH_FUNC as int:
        get
    STENCIL_CLEAR_VALUE as int:
        get
    STENCIL_FUNC as int:
        get
    STENCIL_FAIL as int:
        get
    STENCIL_PASS_DEPTH_FAIL as int:
        get
    STENCIL_PASS_DEPTH_PASS as int:
        get
    STENCIL_REF as int:
        get
    STENCIL_VALUE_MASK as int:
        get
    STENCIL_WRITEMASK as int:
        get
    STENCIL_BACK_FUNC as int:
        get
    STENCIL_BACK_FAIL as int:
        get
    STENCIL_BACK_PASS_DEPTH_FAIL as int:
        get
    STENCIL_BACK_PASS_DEPTH_PASS as int:
        get
    STENCIL_BACK_REF as int:
        get
    STENCIL_BACK_VALUE_MASK as int:
        get
    STENCIL_BACK_WRITEMASK as int:
        get
    VIEWPORT as int:
        get
    SCISSOR_BOX as int:
        get
    # SCISSOR_TEST
    COLOR_CLEAR_VALUE as int:
        get
    COLOR_WRITEMASK as int:
        get
    UNPACK_ALIGNMENT as int:
        get
    PACK_ALIGNMENT as int:
        get
    MAX_TEXTURE_SIZE as int:
        get
    MAX_VIEWPORT_DIMS as int:
        get
    SUBPIXEL_BITS as int:
        get
    RED_BITS as int:
        get
    GREEN_BITS as int:
        get
    BLUE_BITS as int:
        get
    ALPHA_BITS as int:
        get
    DEPTH_BITS as int:
        get
    STENCIL_BITS as int:
        get
    POLYGON_OFFSET_UNITS as int:
        get
    # POLYGON_OFFSET_FILL
    POLYGON_OFFSET_FACTOR as int:
        get
    TEXTURE_BINDING_2D as int:
        get
    SAMPLE_BUFFERS as int:
        get
    SAMPLES as int:
        get
    SAMPLE_COVERAGE_VALUE as int:
        get
    SAMPLE_COVERAGE_INVERT as int:
        get

    # GetTextureParameter
    # TEXTURE_MAG_FILTER
    # TEXTURE_MIN_FILTER
    # TEXTURE_WRAP_S
    # TEXTURE_WRAP_T

    COMPRESSED_TEXTURE_FORMATS as int:
        get

    # HintMode
    DONT_CARE as int:
        get
    FASTEST as int:
        get
    NICEST as int:
        get

    # HintTarget
    GENERATE_MIPMAP_HINT as int:
        get

    # DataType
    BYTE as int:
        get
    UNSIGNED_BYTE as int:
        get
    SHORT as int:
        get
    UNSIGNED_SHORT as int:
        get
    INT as int:
        get
    UNSIGNED_INT as int:
        get
    FLOAT as int:
        get

    # PixelFormat
    DEPTH_COMPONENT as int:
        get
    ALPHA as int:
        get
    RGB as int:
        get
    RGBA as int:
        get
    LUMINANCE as int:
        get
    LUMINANCE_ALPHA as int:
        get

    # PixelType
    # UNSIGNED_BYTE
    UNSIGNED_SHORT_4_4_4_4 as int:
        get
    UNSIGNED_SHORT_5_5_5_1 as int:
        get
    UNSIGNED_SHORT_5_6_5 as int:
        get

    # Shaders
    FRAGMENT_SHADER as int:
        get
    VERTEX_SHADER as int:
        get
    MAX_VERTEX_ATTRIBS as int:
        get
    MAX_VERTEX_UNIFORM_VECTORS as int:
        get
    MAX_VARYING_VECTORS as int:
        get
    MAX_COMBINED_TEXTURE_IMAGE_UNITS as int:
        get
    MAX_VERTEX_TEXTURE_IMAGE_UNITS as int:
        get
    MAX_TEXTURE_IMAGE_UNITS as int:
        get
    MAX_FRAGMENT_UNIFORM_VECTORS as int:
        get
    SHADER_TYPE as int:
        get
    DELETE_STATUS as int:
        get
    LINK_STATUS as int:
        get
    VALIDATE_STATUS as int:
        get
    ATTACHED_SHADERS as int:
        get
    ACTIVE_UNIFORMS as int:
        get
    ACTIVE_ATTRIBUTES as int:
        get
    SHADING_LANGUAGE_VERSION as int:
        get
    CURRENT_PROGRAM as int:
        get

    # StencilFunction
    NEVER as int:
        get
    LESS as int:
        get
    EQUAL as int:
        get
    LEQUAL as int:
        get
    GREATER as int:
        get
    NOTEQUAL as int:
        get
    GEQUAL as int:
        get
    ALWAYS as int:
        get

    # StencilOp
    # ZERO
    KEEP as int:
        get
    REPLACE as int:
        get
    INCR as int:
        get
    DECR as int:
        get
    INVERT as int:
        get
    INCR_WRAP as int:
        get
    DECR_WRAP as int:
        get

    # StringName
    VENDOR as int:
        get
    RENDERER as int:
        get
    VERSION as int:
        get

    # TextureMagFilter
    NEAREST as int:
        get
    LINEAR as int:
        get

    # TextureMinFilter
    # NEAREST
    # LINEAR
    NEAREST_MIPMAP_NEAREST as int:
        get
    LINEAR_MIPMAP_NEAREST as int:
        get
    NEAREST_MIPMAP_LINEAR as int:
        get
    LINEAR_MIPMAP_LINEAR as int:
        get

    # TextureParameterName
    TEXTURE_MAG_FILTER as int:
        get
    TEXTURE_MIN_FILTER as int:
        get
    TEXTURE_WRAP_S as int:
        get
    TEXTURE_WRAP_T as int:
        get

    # TextureTarget
    TEXTURE_2D as int:
        get
    TEXTURE as int:
        get

    TEXTURE_CUBE_MAP as int:
        get
    TEXTURE_BINDING_CUBE_MAP as int:
        get
    TEXTURE_CUBE_MAP_POSITIVE_X as int:
        get
    TEXTURE_CUBE_MAP_NEGATIVE_X as int:
        get
    TEXTURE_CUBE_MAP_POSITIVE_Y as int:
        get
    TEXTURE_CUBE_MAP_NEGATIVE_Y as int:
        get
    TEXTURE_CUBE_MAP_POSITIVE_Z as int:
        get
    TEXTURE_CUBE_MAP_NEGATIVE_Z as int:
        get
    MAX_CUBE_MAP_TEXTURE_SIZE as int:
        get

    # TextureUnit
    TEXTURE0 as int:
        get
    TEXTURE1 as int:
        get
    TEXTURE2 as int:
        get
    TEXTURE3 as int:
        get
    TEXTURE4 as int:
        get
    TEXTURE5 as int:
        get
    TEXTURE6 as int:
        get
    TEXTURE7 as int:
        get
    TEXTURE8 as int:
        get
    TEXTURE9 as int:
        get
    TEXTURE10 as int:
        get
    TEXTURE11 as int:
        get
    TEXTURE12 as int:
        get
    TEXTURE13 as int:
        get
    TEXTURE14 as int:
        get
    TEXTURE15 as int:
        get
    TEXTURE16 as int:
        get
    TEXTURE17 as int:
        get
    TEXTURE18 as int:
        get
    TEXTURE19 as int:
        get
    TEXTURE20 as int:
        get
    TEXTURE21 as int:
        get
    TEXTURE22 as int:
        get
    TEXTURE23 as int:
        get
    TEXTURE24 as int:
        get
    TEXTURE25 as int:
        get
    TEXTURE26 as int:
        get
    TEXTURE27 as int:
        get
    TEXTURE28 as int:
        get
    TEXTURE29 as int:
        get
    TEXTURE30 as int:
        get
    TEXTURE31 as int:
        get
    ACTIVE_TEXTURE as int:
        get

    # TextureWrapMode
    REPEAT as int:
        get
    CLAMP_TO_EDGE as int:
        get
    MIRRORED_REPEAT as int:
        get

    # Uniform Types
    FLOAT_VEC2 as int:
        get
    FLOAT_VEC3 as int:
        get
    FLOAT_VEC4 as int:
        get
    INT_VEC2 as int:
        get
    INT_VEC3 as int:
        get
    INT_VEC4 as int:
        get
    BOOL as int:
        get
    BOOL_VEC2 as int:
        get
    BOOL_VEC3 as int:
        get
    BOOL_VEC4 as int:
        get
    FLOAT_MAT2 as int:
        get
    FLOAT_MAT3 as int:
        get
    FLOAT_MAT4 as int:
        get
    SAMPLER_2D as int:
        get
    SAMPLER_CUBE as int:
        get

    # Vertex Arrays
    VERTEX_ATTRIB_ARRAY_ENABLED as int:
        get
    VERTEX_ATTRIB_ARRAY_SIZE as int:
        get
    VERTEX_ATTRIB_ARRAY_STRIDE as int:
        get
    VERTEX_ATTRIB_ARRAY_TYPE as int:
        get
    VERTEX_ATTRIB_ARRAY_NORMALIZED as int:
        get
    VERTEX_ATTRIB_ARRAY_POINTER as int:
        get
    VERTEX_ATTRIB_ARRAY_BUFFER_BINDING as int:
        get

    # Shader Source
    COMPILE_STATUS as int:
        get

    # Shader Precision-Specified Types
    LOW_FLOAT as int:
        get
    MEDIUM_FLOAT as int:
        get
    HIGH_FLOAT as int:
        get
    LOW_INT as int:
        get
    MEDIUM_INT as int:
        get
    HIGH_INT as int:
        get

    # Framebuffer Object.
    FRAMEBUFFER as int:
        get
    RENDERBUFFER as int:
        get

    RGBA4 as int:
        get
    RGB5_A1 as int:
        get
    RGB565 as int:
        get
    DEPTH_COMPONENT16 as int:
        get
    STENCIL_INDEX as int:
        get
    STENCIL_INDEX8 as int:
        get
    DEPTH_STENCIL as int:
        get

    RENDERBUFFER_WIDTH as int:
        get
    RENDERBUFFER_HEIGHT as int:
        get
    RENDERBUFFER_INTERNAL_FORMAT as int:
        get
    RENDERBUFFER_RED_SIZE as int:
        get
    RENDERBUFFER_GREEN_SIZE as int:
        get
    RENDERBUFFER_BLUE_SIZE as int:
        get
    RENDERBUFFER_ALPHA_SIZE as int:
        get
    RENDERBUFFER_DEPTH_SIZE as int:
        get
    RENDERBUFFER_STENCIL_SIZE as int:
        get

    FRAMEBUFFER_ATTACHMENT_OBJECT_TYPE as int:
        get
    FRAMEBUFFER_ATTACHMENT_OBJECT_NAME as int:
        get
    FRAMEBUFFER_ATTACHMENT_TEXTURE_LEVEL as int:
        get
    FRAMEBUFFER_ATTACHMENT_TEXTURE_CUBE_MAP_FACE as int:
        get

    COLOR_ATTACHMENT0 as int:
        get
    DEPTH_ATTACHMENT as int:
        get
    STENCIL_ATTACHMENT as int:
        get
    DEPTH_STENCIL_ATTACHMENT as int:
        get

    NONE as int:
        get

    FRAMEBUFFER_COMPLETE as int:
        get
    FRAMEBUFFER_INCOMPLETE_ATTACHMENT as int:
        get
    FRAMEBUFFER_INCOMPLETE_MISSING_ATTACHMENT as int:
        get
    FRAMEBUFFER_INCOMPLETE_DIMENSIONS as int:
        get
    FRAMEBUFFER_UNSUPPORTED as int:
        get

    FRAMEBUFFER_BINDING as int:
        get
    RENDERBUFFER_BINDING as int:
        get
    MAX_RENDERBUFFER_SIZE as int:
        get

    INVALID_FRAMEBUFFER_OPERATION as int:
        get

    # WebGL-specific enums
    UNPACK_FLIP_Y_WEBGL as int:
        get
    UNPACK_PREMULTIPLY_ALPHA_WEBGL as int:
        get
    CONTEXT_LOST_WEBGL as int:
        get
    UNPACK_COLORSPACE_CONVERSION_WEBGL as int:
        get
    BROWSER_DEFAULT_WEBGL as int:
        get


    canvas as HTMLCanvasElement:
        get

    drawingBufferWidth as int:
        get
    drawingBufferHeight as int:
        get


    def getContextAttributes() as WebGLContextAttributes
    def isContextLost() as bool

    def getSupportedExtensions() as (string)
    def getExtension(name as string) as object

    def activeTexture(texture as double)
    def attachShader(program as WebGLProgram, shader as WebGLShader)
    def bindAttribLocation(program as WebGLProgram, index as double, name as string)
    def bindBuffer(target as double, buffer as WebGLBuffer)
    def bindFramebuffer(target as double, framebuffer as WebGLFramebuffer)
    def bindRenderbuffer(target as double, renderbuffer as WebGLRenderbuffer)
    def bindTexture(target as double, texture as WebGLTexture)
    def blendColor(red as double, green as double, blue as double, alpha as double)
    def blendEquation(mode as double)
    def blendEquationSeparate(modeRGB as double, modeAlpha as double)
    def blendFunc(sfactor as double, dfactor as double)
    def blendFuncSeparate(srcRGB as double, dstRGB as double, srcAlpha as double, dstAlpha as double)

    def bufferData(target as double, size as double, usage as double)
    def bufferData(target as double, data as ArrayBufferView, usage as double)
    def bufferData(target as double, data as ArrayBuffer, usage as double)
    def bufferSubData(target as double, offset as double, data as ArrayBufferView)
    def bufferSubData(target as double, offset as double, data as ArrayBuffer)

    def checkFramebufferStatus(target as double) as double
    def clear(mask as double)
    def clearColor(red as double, green as double, blue as double, alpha as double)
    def clearDepth(depth as double)
    def clearStencil(s as double)
    def colorMask(red as bool, green as bool, blue as bool, alpha as bool)
    def compileShader(shader as WebGLShader)

    def compressedTexImage2D(target as double, level as double, internalformat as double, width as double, height as double, border as double, data as ArrayBufferView)
    def compressedTexSubImage2D(target as double, level as double, xoffset as double, yoffset as double, width as double, height as double, format as double, data as ArrayBufferView)

    def copyTexImage2D(target as double, level as double, internalformat as double, x as double, y as double, width as double, height as double, border as double)
    def copyTexSubImage2D(target as double, level as double, xoffset as double, yoffset as double, x as double, y as double, width as double, height as double)

    def createBuffer() as WebGLBuffer
    def createFramebuffer() as WebGLFramebuffer
    def createProgram() as WebGLProgram
    def createRenderbuffer() as WebGLRenderbuffer
    def createShader(type as double) as WebGLShader
    def createTexture() as WebGLTexture

    def cullFace(mode as double)

    def deleteBuffer(buffer as WebGLBuffer)
    def deleteFramebuffer(framebuffer as WebGLFramebuffer)
    def deleteProgram(program as WebGLProgram)
    def deleteRenderbuffer(renderbuffer as WebGLRenderbuffer)
    def deleteShader(shader as WebGLShader)
    def deleteTexture(texture as WebGLTexture)

    def depthFunc(func as double)
    def depthMask(flag as bool)
    def depthRange(zNear as double, zFar as double)
    def detachShader(program as WebGLProgram, shader as WebGLShader)
    def disable(cap as double)
    def disableVertexAttribArray(index as double)
    def drawArrays(mode as double, first as double, count as double)
    def drawElements(mode as double, count as double, type as double, offset as double)

    def enable(cap as double)
    def enableVertexAttribArray(index as double)
    def finish()
    def flush()
    def framebufferRenderbuffer(target as double, attachment as double, renderbuffertarget as double, renderbuffer as WebGLRenderbuffer)
    def framebufferTexture2D(target as double, attachment as double, textarget as double, texture as WebGLTexture, level as double)
    def frontFace(mode as double)

    def generateMipmap(target as double)

    def getActiveAttrib(program as WebGLProgram, index as double) as WebGLActiveInfo
    def getActiveUniform(program as WebGLProgram, index as double) as WebGLActiveInfo
    def getAttachedShaders(program as WebGLProgram) as (WebGLShader)

    def getAttribLocation(program as WebGLProgram, name as string) as double

    def getBufferParameter(target as double, pname as double) as object
    def getParameter(pname as double) as object

    def getError() as double

    def getFramebufferAttachmentParameter(target as double, attachment as double, pname as double) as object
    def getProgramParameter(program as WebGLProgram, pname as double) as object
    def getProgramInfoLog(program as WebGLProgram) as string
    def getRenderbufferParameter(target as double, pname as double) as object
    def getShaderParameter(shader as WebGLShader, pname as double) as object
    def getShaderPrecisionFormat(shadertype as double, precisiontype as double) as WebGLShaderPrecisionFormat
    def getShaderInfoLog(shader as WebGLShader) as string

    def getShaderSource(shader as WebGLShader) as string

    def getTexParameter(target as double, pname as double) as object

    def getUniform(program as WebGLProgram, location as WebGLUniformLocation) as object

    def getUniformLocation(program as WebGLProgram, name as string) as WebGLUniformLocation

    def getVertexAttrib(index as double, pname as double) as object

    def getVertexAttribOffset(index as double, pname as double) as double

    def hint(target as double, mode as double)
    def isBuffer(buffer as WebGLBuffer) as bool
    def isEnabled(cap as double) as bool
    def isFramebuffer(framebuffer as WebGLFramebuffer) as bool
    def isProgram(program as WebGLProgram) as bool
    def isRenderbuffer(renderbuffer as WebGLRenderbuffer) as bool
    def isShader(shader as WebGLShader) as bool
    def isTexture(texture as WebGLTexture) as bool
    def lineWidth(width as double)
    def linkProgram(program as WebGLProgram)
    def pixelStorei(pname as double, param as double)
    def polygonOffset(factor as double, units as double)

    def readPixels(x as double, y as double, width as double, height as double, format as double, type as double, pixels as ArrayBufferView)

    def renderbufferStorage(target as double, internalformat as double, width as double, height as double)
    def sampleCoverage(value as double, invert as bool)
    def scissor(x as double, y as double, width as double, height as double)

    def shaderSource(shader as WebGLShader, source as string)

    def stencilFunc(func as double, refe as double, mask as double)
    def stencilFuncSeparate(face as double, func as double, refe as double, mask as double)
    def stencilMask(mask as double)
    def stencilMaskSeparate(face as double, mask as double)
    def stencilOp(fail as double, zfail as double, zpass as double)
    def stencilOpSeparate(face as double, fail as double, zfail as double, zpass as double)

    def texImage2D(target as double, level as double, internalformat as double, width as double, height as double, border as double, format as double, type as double, pixels as ArrayBufferView)
    def texImage2D(target as double, level as double, internalformat as double, format as double, type as double, pixels as ImageData)
    def texImage2D(target as double, level as double, internalformat as double, format as double, type as double, image as HTMLImageElement) // May throw DOMException
    def texImage2D(target as double, level as double, internalformat as double, format as double, type as double, canvas as HTMLCanvasElement) // May throw DOMException
    def texImage2D(target as double, level as double, internalformat as double, format as double, type as double, video as HTMLVideoElement) // May throw DOMException

    def texParameterf(target as double, pname as double, param as double)
    def texParameteri(target as double, pname as double, param as double)

    def texSubImage2D(target as double, level as double, xoffset as double, yoffset as double, width as double, height as double, format as double, type as double, pixels as ArrayBufferView)
    def texSubImage2D(target as double, level as double, xoffset as double, yoffset as double, format as double, type as double, pixels as ImageData)
    def texSubImage2D(target as double, level as double, xoffset as double, yoffset as double, format as double, type as double, image as HTMLImageElement) // May throw DOMException
    def texSubImage2D(target as double, level as double, xoffset as double, yoffset as double, format as double, type as double, canvas as HTMLCanvasElement) // May throw DOMException
    def texSubImage2D(target as double, level as double, xoffset as double, yoffset as double, format as double, type as double, video as HTMLVideoElement) // May throw DOMException

    def uniform1f(location as WebGLUniformLocation, x as double)
    def uniform1fv(location as WebGLUniformLocation, v as Float32Array)
    def uniform1fv(location as WebGLUniformLocation, v as (double))
    def uniform1i(location as WebGLUniformLocation, x as double)
    def uniform1iv(location as WebGLUniformLocation, v as Int32Array)
    def uniform1iv(location as WebGLUniformLocation, v as (double))
    def uniform2f(location as WebGLUniformLocation, x as double, y as double)
    def uniform2fv(location as WebGLUniformLocation, v as Float32Array)
    def uniform2fv(location as WebGLUniformLocation, v as (double))
    def uniform2i(location as WebGLUniformLocation, x as double, y as double)
    def uniform2iv(location as WebGLUniformLocation, v as Int32Array)
    def uniform2iv(location as WebGLUniformLocation, v as (double))
    def uniform3f(location as WebGLUniformLocation, x as double, y as double, z as double)
    def uniform3fv(location as WebGLUniformLocation, v as Float32Array)
    def uniform3fv(location as WebGLUniformLocation, v as (double))
    def uniform3i(location as WebGLUniformLocation, x as double, y as double, z as double)
    def uniform3iv(location as WebGLUniformLocation, v as Int32Array)
    def uniform3iv(location as WebGLUniformLocation, v as (double))
    def uniform4f(location as WebGLUniformLocation, x as double, y as double, z as double, w as double)
    def uniform4fv(location as WebGLUniformLocation, v as Float32Array)
    def uniform4fv(location as WebGLUniformLocation, v as (double))
    def uniform4i(location as WebGLUniformLocation, x as double, y as double, z as double, w as double)
    def uniform4iv(location as WebGLUniformLocation, v as Int32Array)
    def uniform4iv(location as WebGLUniformLocation, v as (double))

    def uniformMatrix2fv(location as WebGLUniformLocation, transpose as bool, value as Float32Array)
    def uniformMatrix2fv(location as WebGLUniformLocation, transpose as bool, value as (double))
    def uniformMatrix3fv(location as WebGLUniformLocation, transpose as bool, value as Float32Array)
    def uniformMatrix3fv(location as WebGLUniformLocation, transpose as bool, value as (double))
    def uniformMatrix4fv(location as WebGLUniformLocation, transpose as bool, value as Float32Array)
    def uniformMatrix4fv(location as WebGLUniformLocation, transpose as bool, value as (double))

    def useProgram(program as WebGLProgram)
    def validateProgram(program as WebGLProgram)

    def vertexAttrib1f(indx as double, x as double)
    def vertexAttrib1fv(indx as double, values as Float32Array)
    def vertexAttrib1fv(indx as double, value as (double))
    def vertexAttrib2f(indx as double, x as double, y as double)
    def vertexAttrib2fv(indx as double, values as Float32Array)
    def vertexAttrib2fv(indx as double, value as (double))
    def vertexAttrib3f(indx as double, x as double, y as double, z as double)
    def vertexAttrib3fv(indx as double, values as Float32Array)
    def vertexAttrib3fv(indx as double, value as (double))
    def vertexAttrib4f(indx as double, x as double, y as double, z as double, w as double)
    def vertexAttrib4fv(indx as double, values as Float32Array)
    def vertexAttrib4fv(indx as double, value as (double))
    def vertexAttribPointer(indx as double, size as double, type as double, normalized as bool, stride as double, offset as double)

    def viewport(x as double, y as double, width as double, height as double)

