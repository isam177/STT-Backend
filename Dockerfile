FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# Install Python, ffmpeg, wget, and unzip in base stage
RUN apt-get update && \
    apt-get install -y python3 python3-pip ffmpeg wget unzip && \
    ln -s /usr/bin/python3 /usr/bin/python && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Use the official .NET SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy everything and build
COPY . .
RUN dotnet publish -c Release -o out

# Use the base stage (which has Python) for the final container
FROM base AS final
WORKDIR /app
COPY --from=build /app/out .

# Copy your Python script
COPY ToText.py .

# Install Python dependencies for your script (bypass externally-managed-environment)
RUN pip3 install --no-cache-dir --break-system-packages \
    openai-whisper \
    SpeechRecognition \
    torch \
    torchaudio \
    numpy \
    vosk

# Download a Vosk language model (small English model)
RUN mkdir -p /app/vosk-models && \
    wget -O /tmp/vosk-model.zip https://alphacephei.com/vosk/models/vosk-model-small-en-us-0.15.zip && \
    unzip /tmp/vosk-model.zip -d /app/vosk-models && \
    rm /tmp/vosk-model.zip

# Set environment variables for Render
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
ENV ASPNETCORE_ENVIRONMENT=Production

# Expose port 8080 (Render's default)
EXPOSE 8080

# Tell Render how to run your app
ENTRYPOINT ["dotnet", "STT.dll"]