FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY frontend/ ./
RUN dotnet publish frontend.csproj -c Release -o /app

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app .
ENV ASPNETCORE_FORWARDEDHEADERS_ENABLED=true
CMD ["sh", "-c", "ASPNETCORE_URLS=http://0.0.0.0:${PORT:-8080} dotnet frontend.dll"]
