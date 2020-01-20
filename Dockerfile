#See https://aka.ms/containerfastmode to understand how Visual Studio uses this Dockerfile to build your images for faster debugging.

FROM mcr.microsoft.com/dotnet/core/aspnet:3.1-buster-slim AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/core/sdk:3.1-buster AS build
WORKDIR /src
COPY ["debristicket.csproj", "./"]
RUN apt-get install --yes curl
RUN curl --silent --location https://deb.nodesource.com/setup_12.x | bash -
RUN apt-get install --yes nodejs
RUN dotnet restore "debristicket.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "debristicket.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "debristicket.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "debristicket.dll"]
