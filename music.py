import numpy as np
import wave

music = wave.open("C:/Users/Howar/Desktop/test.wav", 'r')
signal = music.readframes(-1)

soundwave = np.frombuffer(signal, dtype="uint16")

with open("C:/Users/Howar/Desktop/test.txt","w") as f:
    for i in soundwave:
        f.write('{:04X}'.format(i))
        f.write("\n")