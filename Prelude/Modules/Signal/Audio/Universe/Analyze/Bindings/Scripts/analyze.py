#!/usr/bin/env python3
"""Audio spectral analysis - chromagram, spectrogram, tonnetz visualization"""
import sys
import librosa
import librosa.display
import matplotlib.pyplot as plt
import numpy as np

def analyze(audio_path, output_dir="."):
    print(f"Loading {audio_path}...")
    y, sr = librosa.load(audio_path, sr=22050)
    duration = librosa.get_duration(y=y, sr=sr)
    print(f"Duration: {duration:.1f}s, Sample rate: {sr}Hz")
    
    # 1. Chromagram - pitch class distribution
    print("Computing chromagram...")
    chroma = librosa.feature.chroma_cqt(y=y, sr=sr)
    
    plt.figure(figsize=(14, 4))
    librosa.display.specshow(chroma, y_axis='chroma', x_axis='time', sr=sr)
    plt.colorbar(label='Intensity')
    plt.title('Chromagram - Pitch Class Distribution Over Time')
    plt.ylabel('Pitch Class')
    plt.tight_layout()
    plt.savefig(f'{output_dir}/chromagram.png', dpi=150)
    print(f"Saved {output_dir}/chromagram.png")
    
    # 2. Spectrogram - full frequency content
    print("Computing spectrogram...")
    D = librosa.amplitude_to_db(np.abs(librosa.stft(y)), ref=np.max)
    
    plt.figure(figsize=(14, 4))
    librosa.display.specshow(D, y_axis='log', x_axis='time', sr=sr)
    plt.colorbar(format='%+2.0f dB', label='Amplitude')
    plt.title('Spectrogram - Frequency Content Over Time')
    plt.ylabel('Frequency (Hz)')
    plt.tight_layout()
    plt.savefig(f'{output_dir}/spectrogram.png', dpi=150)
    print(f"Saved {output_dir}/spectrogram.png")
    
    # 3. Tonnetz - harmonic geometry
    print("Computing tonnetz...")
    tonnetz = librosa.feature.tonnetz(y=y, sr=sr)
    
    plt.figure(figsize=(14, 4))
    librosa.display.specshow(tonnetz, y_axis='tonnetz', x_axis='time', sr=sr)
    plt.colorbar(label='Coefficient')
    plt.title('Tonnetz - Harmonic Structure (5ths, minor 3rds, major 3rds)')
    plt.tight_layout()
    plt.savefig(f'{output_dir}/tonnetz.png', dpi=150)
    print(f"Saved {output_dir}/tonnetz.png")
    
    # 4. Key estimation
    print("Estimating key...")
    chroma_mean = np.mean(chroma, axis=1)
    key_names = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B']
    estimated_key = key_names[np.argmax(chroma_mean)]
    print(f"Estimated key center: {estimated_key}")
    
    # 5. Tempo
    tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
    print(f"Estimated tempo: {tempo:.1f} BPM")
    
    print("\nAnalysis complete!")
    return {
        'duration': duration,
        'key': estimated_key,
        'tempo': float(tempo),
    }

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print("Usage: python analyze.py <audio_file> [output_dir]")
        sys.exit(1)
    
    audio_path = sys.argv[1]
    output_dir = sys.argv[2] if len(sys.argv) > 2 else "."
    analyze(audio_path, output_dir)
