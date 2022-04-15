import sys

with open(sys.argv[1], "rb") as f:
    print(sys.argv[1])
    byte = f.read(1)
    s = ".db "
    z = 0
    while byte != b"\n":
        byte = f.read(1)
    byte = f.read(1)
    while byte != b"\n":
        byte = f.read(1)
    byte = f.read(1)
    while byte != b"":
        # Do stuff with byte.
        s = s + "$" + byte.hex()
        z = z + 1
        if z == 24:
            print(s)
            s = ".db "
            z = 0
        else:
            s = s + ","
        byte = f.read(1)
    print(s) # ha a fájl nem osztható 24 vel