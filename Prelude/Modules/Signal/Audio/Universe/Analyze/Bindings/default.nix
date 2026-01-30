# Analyze Bindings - analysis scripts
{ ... }: { }

# Usage from devShell:
# python -c "
# import librosa
# import librosa.display
# import matplotlib.pyplot as plt
# import numpy as np
#
# y, sr = librosa.load('audio.mp3')
#
# # Chromagram - pitch class over time
# chroma = librosa.feature.chroma_cqt(y=y, sr=sr)
# plt.figure(figsize=(12, 4))
# librosa.display.specshow(chroma, y_axis='chroma', x_axis='time')
# plt.colorbar()
# plt.title('Chromagram')
# plt.savefig('chromagram.png')
#
# # Spectrogram
# D = librosa.amplitude_to_db(np.abs(librosa.stft(y)), ref=np.max)
# plt.figure(figsize=(12, 4))
# librosa.display.specshow(D, y_axis='log', x_axis='time')
# plt.colorbar(format='%+2.0f dB')
# plt.title('Spectrogram')
# plt.savefig('spectrogram.png')
#
# # Tonnetz - harmonic structure
# tonnetz = librosa.feature.tonnetz(y=y, sr=sr)
# plt.figure(figsize=(12, 4))
# librosa.display.specshow(tonnetz, y_axis='tonnetz', x_axis='time')
# plt.colorbar()
# plt.title('Tonnetz')
# plt.savefig('tonnetz.png')
# "
