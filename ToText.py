import sys
import whisper
import speech_recognition as sr
import subprocess
import json
import os

if __name__ == "__main__":

    re = sr.Recognizer()
    file = sys.argv[1]
    #print("file:" , file)
    base = os.path.splitext(file)[0]
    #print("base: ", base)
    wav_file = base + ".wav"

    res = subprocess.run(["ffmpeg", "-y", "-i", file, wav_file], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    if( res.returncode !=0):
        print("ffmpeg failed")
        print(res.stderr)
        sys.exit(1)
    try:
        with sr.AudioFile(wav_file) as source:
            audio = re.record(source)
        #print("Current working directory:", os.getcwd())
        text = re.recognize_vosk(audio)
        text = json.loads(text)
        text = text["text"]   
        print(text)
    except Exception as e:
        print("failed to load because " , e)

