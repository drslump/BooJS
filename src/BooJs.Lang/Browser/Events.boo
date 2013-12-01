namespace BooJs.Lang.Browser

from BooJs.Lang.Browser.Dom3 import Document, DOMStringList


interface StyleMedia:
    type as string:
        get
    def matchMedium(mediaquery as string) as bool

interface Blob:
    type as string:
        get
    size as int:
        get

    def slice() as Blob
    def slice(start as int) as Blob
    def slice(start as int, end as int) as Blob
    def slice(start as int, end as int, contentType as string) as Blob

interface File(Blob):
    lastModifiedDate as object:
        get
    name as string:
        get

interface FileList:
    length as int:
        get
    self[index as int] as File:
        get
    def item(index as int) as File

interface DataTransfer:
    types as DOMStringList:
        get
    files as FileList:
        get

interface AbstractView:
    styleMedia as StyleMedia:
        get
    document as Document:
        get

callable EventListener(evt as Event)

interface EventTarget:
   def removeEventListener(type as string, listener as EventListener)
   def removeEventListener(type as string, listener as EventListener, useCapture as bool)
   def addEventListener(type as string, listener as EventListener)
   def addEventListener(type as string, listener as EventListener, useCapture as bool)
   def dispatchEvent(evt as Event) as bool

interface Event:
    CAPTURING_PHASE as int:
        get
    AT_TARGET as int:
        get
    BUBBLING_PHASE as int:
        get

    timeStamp as double:
        get
    defaultPrevented as bool:
        get
    isTrusted as bool:
        get
    currentTarget as EventTarget:
        get
    target as EventTarget:
        get
    eventPhase as int:
        get
    type as string:
        get
    cancelable as bool:
        get
    bubbles as bool:
        get

    def stopPropagation()
    def stopImmediatePropagation()
    def preventDefault()

interface UIEvent(Event):
    detail as double:
        get
    view as AbstractView:
        get

interface FocusEvent(UIEvent):
    relatedTarget as EventTarget:
        get

interface KeyboardEvent(UIEvent):
    DOM_KEY_LOCATION_RIGHT as int:
        get
    DOM_KEY_LOCATION_STANDARD as int:
        get
    DOM_KEY_LOCATION_LEFT as int:
        get
    DOM_KEY_LOCATION_NUMPAD as int:
        get
    DOM_KEY_LOCATION_JOYSTICK as int:
        get
    DOM_KEY_LOCATION_MOBILE as int:
        get

    location as double:
        get
    shiftKey as bool:
        get
    locale as string:
        get
    key as string:
        get
    altKey as bool:
        get
    metaKey as bool:
        get
    @char as string:
        get
    ctrlKey as bool:
        get
    repeat as bool:
        get

    def getModifierState(keyArg as string) as bool


interface MouseEvent(UIEvent):
    pageX as int:
        get
    offsetY as int:
        get
    x as int:
        get
    y as int:
        get
    altKey as bool:
        get
    metaKey as bool:
        get
    ctrlKey as bool:
        get
    offsetX as int:
        get
    screenX as int:
        get
    clientY as int:
        get
    shiftKey as bool:
        get
    screenY as int:
        get
    relatedTarget as EventTarget:
        get
    button as int:
        get
    pageY as int:
        get
    buttons as int:
        get
    clientX as int:
        get

    def getModifierState(keyArg as string) as bool


interface MouseWheelEvent(MouseEvent):
    wheelDelta as double:
        get


interface DragEvent(MouseEvent):
    dataTransfer as DataTransfer:
        get

