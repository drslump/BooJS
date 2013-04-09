"""
Types for HTML5 Canvas

Ref: http://www.w3.org/TR/html-markup/canvas.html
Ref: http://www.w3.org/TR/2dcontext/
"""

namespace Browser

import BooJs.Lang.Extensions
import BooJs.Lang.Globals
import Browser.Dom3(Element)


[Extern]
class HTMLCanvasElement(Element):

    public width as uint
    public height as uint

    def toDataURL() as string:
        pass
    def toDataURL(type as string) as string:
        pass
    def toDataURL(type as string, *args as (object)) as string:
        pass

    def toDataURLHD() as string:
        pass
    def toDataURLHD(type as string) as string:
        pass
    def toDataURLHD(type as string, *args as (object)) as string:
        pass

    def toBlob(callback as callable):
        pass
    def toBlob(callback as callable, type as string):
        pass
    def toBlob(callback as callable, type as string, *args as (object)):
        pass

    def toBlobHD(callback as callable):
        pass
    def toBlobHD(callback as callable, type as string):
        pass
    def toBlobHD(callback as callable, type as string, *args as (object)):
        pass

    def getContext(contextId as string) as CanvasRenderingContext2D:
        pass
    def getContext(contextId as string, *args as (object)) as CanvasRenderingContext2D:
        pass


interface CanvasRenderingContext2D(CanvasDrawingStyles, CanvasPathMethods):

    # back-reference to the canvas
    canvas as HTMLCanvasElement:
        get

    # state
    def save()  // push state on state stack
    def restore()  // pop state stack and restore state

    # transformations (default transform is the identity matrix)
    def scale(x as double, y as double)
    def rotate(angle as double)
    def translate(x as double, y as double)
    def transform(a as double, b as double, c as double, d as double, e as double, f as double)
    def setTransform(a as double, b as double, c as double, d as double, e as double, f as double)

    # compositing
    globalAlpha as double:  # (default 1.0)
        get
        set
    globalCompositeOperation as string:  # (default source-over)
        get
        set

    # colors and styles (see also the CanvasDrawingStyles interface)
    strokeStyle as object:  # DOMString or CanvasGradient or CanvasPattern  (default black)
        get
        set

    fillStyle as object:  # DOMString or CanvasGradient or CanvasPattern  (default black)
        get
        set

    def createLinearGradient(x0 as double, y0 as double, x1 as double, y1 as double) as CanvasGradient
    def createRadialGradient(x0 as double, y0 as double, r0 as double, x1 as double, y1 as double, r1 as double) as CanvasGradient
    def createPattern(image as Element) as CanvasPattern
    def createPattern(image as Element, repetition as string) as CanvasPattern

    # shadows
    shadowOffsetX as double:  # (default 0)
        get
        set
    shadowOffsetY as double:  # (default 0)
        get
        set
    shadowBlur as double:  # (default 0)
        get
        set
    shadowColor as string:  # (default transparent black)
        get
        set

    # rects
    def clearRect(x as double, y as double, w as double, h as double)
    def fillRect(x as double, y as double, w as double, h as double)
    def strokeRect(x as double, y as double, w as double, h as double)

    # path API (see also CanvasPathMethods)
    def beginPath()
    def fill()
    def fill(path as Path)
    def stroke()
    def stroke(path as Path)
    def drawSystemFocusRing(element as Element)
    def drawSystemFocusRing(path as Path, element as Element)
    def drawCustomFocusRing(element as Element) as bool
    def drawCustomFocusRing(path as Path, element as Element) as bool
    def scrollPathIntoView()
    def scrollPathIntoView(path as Path)
    def clip()
    def clip(path as Path)
    def isPointInPath(x as double, y as double) as bool
    def isPointInPath(path as Path, x as double, y as double) as bool

    # text (see also the CanvasDrawingStyles interface)
    def fillText(text as string, x as double, y as double)
    def fillText(text as string, x as double, y as double, maxWidth as double)
    def strokeText(text as string, x as double, y as double)
    def strokeText(text as string, x as double, y as double, maxWidth as double)
    def measureText(text as string) as TextMetrics

    # drawing images
    def drawImage(image as Element)
    def drawImage(image as Element, dx as double, dy as double)
    def drawImage(image as Element, dx as double, dy as double, dw as double, dh as double)
    def drawImage(image as Element, sx as double, sy as double, sw as double, sh as double, dx as double, dy as double, dw as double, dh as double)

    # hit regions
    def addHitRegion(options as HitRegionOptions)
    def removeHitRegion(options as HitRegionOptions)

    # pixel manipulation
    def createImageData(sw as double, sh as double) as ImageData
    def createImageData(data as ImageData) as ImageData
    def getImageData(sx as double, sy as double, sw as double, sh as double) as ImageData
    def putImageData(data as ImageData, dx as double, dy as double, dirtyX as double, dirtyY as double, dirtyWidth as double, dirtyHeight as double)
    def putImageData(data as ImageData, dx as double, dy as double)


interface CanvasDrawingStyles:
    # line caps/joins
    lineWidth as double:  # (default 1)
        get
        set
    lineCap as string:  # "butt", "round", "square" (default "butt")
        get
        set
    lineJoin as string:  # "round", "bevel", "miter" (default "miter")
        get
        set
    miterLimit as double:  # (default 10)
        get
        set

    # dashed lines
    def setLineDash(segments as (double))   # default empty
    def getLineDash() as (double)
    lineDashOffset as double:
        get
        set

    # text
    font as string:  # (default 10px sans-serif)
        get
        set
    textAlign as string:  # "start", "end", "left", "right", "center" (default: "start")
        get
        set
    textBaseline as string:  # "top", "hanging", "middle", "alphabetic", "ideographic", "bottom" (default: "alphabetic")
        get
        set


interface CanvasPathMethods:
    # shared path API methods
    def closePath()
    def moveTo(x as double, y as double)
    def lineTo(x as double, y as double)
    def quadraticCurveTo(cpx as double, cpy as double, x as double, y as double)
    def bezierCurveTo(cp1x as double, cp1y as double, cp2x as double, cp2y as double, x as double, y as double)
    def arcTo(x1 as double, y1 as double, x2 as double, y2 as double, radius as double)
    def rect(x as double, y as double, w as double, h as double)
    def arc(x as double, y as double, radius as double, startAngle as double, endAngle as double)
    def arc(x as double, y as double, radius as double, startAngle as double, endAngle as double, anticlockwise as bool)
    def ellipse(x as double, y as double, radiusX as double, radiusY as double, rotation as double, startAngle as double, endAngle as double, anticlockwise as bool)

interface CanvasGradient:
    # opaque object
    def addColorStop(offset as double, color as string)

interface CanvasPattern:
    # opaque object
    pass

interface TextMetrics:
    # x-direction
    width as double:
        get
    actualBoundingBoxLeft as double:
        get
    actualBoundingBoxRight as double:
        get

    # y-direction
    fontBoundingBoxAscent as double:
        get
    fontBoundingBoxDescent as double:
        get
    actualBoundingBoxAscent as double:
        get
    actualBoundingBoxDescent as double:
        get
    emHeightAscent as double:
        get
    emHeightDescent as double:
        get
    hangingBaseline as double:
        get
    alphabeticBaseline as double:
        get
    ideographicBaseline as double:
        get

interface HitRegionOptions:
    path as Path:
        get
        set
    id as string:
        get
        set
    parentID as string:
        get
        set
    cursor as string:   # "inherit"
        get
        set
    # for control-backed regions
    control as Element:
        get
        set
    # for unbacked regions:
    label as string:
        get
        set
    role as string:
        get
        set

interface ImageData:
    width as uint:
        get
    height as uint:
        get
    data as Array: #Uint8ClampedArray:
        get


interface DrawingStyle(CanvasDrawingStyles):
    pass

interface Path(CanvasPathMethods):
    def addPath(path as Path, transformation as object/*SVGMatrix*/)
    def addPathByStrokingPath(path as Path, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/)
    def addText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, x as double, y as double)
    def addText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, x as double, y as double, maxWidth as double)
    def addPathByStrokingText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, x as double, y as double)
    def addPathByStrokingText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, x as double, y as double, maxWidth as double)
    def addText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, path as Path)
    def addText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, path as Path, maxWidth as double)
    def addPathByStrokingText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, path as Path)
    def addPathByStrokingText(text as string, styles as CanvasDrawingStyles, transformation as object/*SVGMatrix*/, path as Path, maxWidth as double)


