namespace BooJs.Lang.Browser

import BooJs.Lang.Browser.Dom3(Element, NodeList)


callable EventListenerKeyboard(ev as KeyboardEvent) as object
callable EventListenerMouse(ev as MouseEvent) as object
callable EventListenerDrag(ev as DragEvent) as object

interface HTMLElement(Element):
    ondragend as EventListenerDrag:
        get; set
    onkeydown as EventListenerKeyboard:
        get; set
    ondragover as EventListenerDrag:
        get; set
    onkeyup as EventListenerKeyboard:
        get; set;
    onreset as EventListener:
        get; set
    onmouseup as EventListenerMouse:
        get; set
    ondragstart as EventListenerDrag:
        get; set
    ondrag as EventListenerDrag:
        get; set
    onmouseover as EventListenerMouse:
        get; set
    ondragleave as EventListenerDrag:
        get; set
    onclick as EventListenerMouse:
        get; set
    onwaiting as EventListener:
        get; set
    ondurationchange as EventListener:
        get; set
    onmousedown as EventListenerMouse:
        get; set
    onseeked as EventListener:
        get; set
    onblur as callable(FocusEvent) as object:
        get; set
    onemptied as EventListener:
        get; set
    onseeking as EventListener:
        get; set
    oncanplay as EventListener:
        get; set
    onstalled as EventListener:
        get; set
    onmousemove as EventListenerMouse:
        get; set
    onratechange as EventListener:
        get; set
    onloadstart as EventListener:
        get; set
    ondragenter as EventListenerDrag:
        get; set
    onprogress as callable(object) as object:
        get; set
    ondblclick as EventListenerMouse:
        get; set
    oncontextmenu as EventListenerMouse:
        get; set
    onchange as EventListener:
        get; set
    onloadedmetadata as EventListener:
        get; set
    onerror as EventListener:
        get; set
    onplay as EventListener:
        get; set
    onplaying as EventListener:
        get; set
    oncanplaythrough as EventListener:
        get; set
    onabort as callable(UIEvent) as object:
        get; set
    onreadystatechange as EventListener:
        get; set
    onkeypress as EventListenerKeyboard:
        get; set
    onloadeddata as EventListener:
        get; set
    onsuspend as EventListener:
        get; set
    onfocus as callable(FocusEvent) as object:
        get; set
    ontimeupdate as EventListener:
        get; set
    onselect as callable(UIEvent) as object:
        get; set
    ondrop as EventListenerDrag:
        get; set
    onmouseout as EventListenerMouse:
        get; set
    onended as EventListener:
        get; set
    onscroll as callable(UIEvent) as object:
        get; set
    onmousewheel as callable(MouseWheelEvent) as object:
        get; set
    onvolumechange as EventListener:
        get; set
    onload as EventListener:
        get; set
    oninput as EventListener:
        get; set
    onsubmit as EventListener:
        get; set
    onpause as EventListener:
        get; set

    offsetTop as int:
        get; set

    innerHTML as string:
        get; set
    lang as string:
        get; set
    className as string:
        get; set
    title as string:
        get; set
    outerHTML as string:
        get; set
    offsetLeft as int:
        get; set
    offsetHeight as int:
        get; set
    dir as string:
        get; set

    style as Hash: #StyleCSSProperties:
        get

    isContentEditable as bool:
        get; set
    contentEditable as string:
        get; set
    tabIndex as int:
        get; set
    id as string:
        get; set
    offsetParent as Element:
        get; set
    disabled as bool:
        get; set
    accessKey as string:
        get; set
    offsetWidth as int:
        get; set

    def click()
    def getElementsByClassName(classNames as string) as NodeList
    def scrollIntoView()
    def scrollIntoView(top as bool)
    def focus()
    def blur()
    def insertAdjacentHTML(where as string, html as string)


interface HTMLImageElement(HTMLElement):
    width as int:
        get; set
    naturalHeight as int:
        get
    alt as string:
        get; set
    src as string:
        get; set
    useMap as string:
        get; set
    naturalWidth as int:
        get
    name as string:
        get; set
    height as int:
        get; set
    longDesc as string:
        get; set
    isMap as bool:
        get; set
    complete as bool:
        get; set

interface HTMLVideoElement(HTMLElement):
    pass
