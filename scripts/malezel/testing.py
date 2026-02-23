# Import everyting in the maelzel.core namespace
from maelzel.core import *
import shutil
import os
# pitchtools defines many useful conversion functions from/to notenames, frequencies, midinotes, etc
from pitchtools import f2m

# the display function allows to display the html representation of objects
from IPython.display import display


"""seq = Chain([
    Note(60),
    Note("c#4+"),
    Note("4Eb"),
    Note("4E+20"),
    Note("4G-10hz"),
    Note("442hz"),
])"""
seq = Note(60)

# for path in os.environ['PATH'].split("C:"):
#     print(path)
seq.show()
