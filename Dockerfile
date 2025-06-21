FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
# Install Python in base stage
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python

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

# Copy your Python script and any requirements
COPY your-python-script.py .
# If you have a requirements.txt file, copy and install dependencies
# COPY requirements.txt .
# RUN pip3 install -r requirements.txt

# Tell Render how to run your app
ENTRYPOINT ["dotnet", "STT.dll"]