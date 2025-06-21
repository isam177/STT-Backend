FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base

# Install Python
RUN apt-get update && \
    apt-get install -y python3 python3-pip && \
    ln -s /usr/bin/python3 /usr/bin/python


# Use the official .NET SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /app

# Copy everything and build
COPY . . 
RUN dotnet publish -c Release -o out

# Use the ASP.NET Core runtime image for the final container
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/out .

# Tell Render how to run your app
ENTRYPOINT ["dotnet", "STT.dll"]