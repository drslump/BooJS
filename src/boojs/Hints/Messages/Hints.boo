namespace boojs.Hints.Messages


class Hints:
    struct Hint:
        node as string
        type as string
        name as string
        full as string
        info as string

        # Extra information
        doc as string
        params as List[of string]
        loc as string  # {file}:{ln}:{col}

    public scope = ''
    public hints = List[of Hint]()

