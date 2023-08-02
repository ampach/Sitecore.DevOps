# escape=`

# This Dockerfile will build the Sitecore solution and save the build artifacts for use in
# other images, such as 'cm' and 'rendering'. It does not produce a runnable image itself.

ARG BUILD_IMAGE

# In a separate image (as to not affect layer cache), gather all NuGet-related solution assets, so that
# we have what we need to run a cached NuGet restore in the next layer:
# https://stackoverflow.com/questions/51372791/is-there-a-more-elegant-way-to-copy-specific-files-using-docker-copy-to-the-work/61332002#61332002
# This technique is described here:
# https://docs.microsoft.com/en-us/aspnet/core/host-and-deploy/docker/building-net-docker-images?view=aspnetcore-3.1#the-dockerfile-1
FROM ${BUILD_IMAGE} AS nuget-prep
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

#Nuget.config will be copied at a later step, as we need to add the private fields
COPY server/*.sln server/Directory.Build.props server/Directory.Build.targets server/Packages.props /nuget/
COPY server/src/ /temp/

RUN Invoke-Expression 'robocopy C:/temp C:/nuget/src /s /ndl /njh /njs *.csproj *.scproj Directory.Build.props'

FROM ${BUILD_IMAGE} AS builder
ARG BUILD_CONFIGURATION
ARG JFROG_USERNAME
ARG JFROG_PASSWORD
ARG DEVOPS_USERNAME
ARG DEVOPS_PASSWORD
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]


WORKDIR /build
#Copy the nuget.config separately, and add the private feeds
COPY ./server/nuget.config ./

# Copy prepped NuGet artifacts, and restore as distinct layer to take advantage of caching.
COPY --from=nuget-prep ./nuget ./

# Restore NuGet packages
RUN dotnet restore /p:Configuration=$env:BUILD_CONFIGURATION --configfile .\nuget.config

#RUN dotnet restore --configfile .\nuget.config

# Copy remaining source code
COPY server/src/ ./src/

# Copy transforms, retaining directory structure
RUN Invoke-Expression 'robocopy /build/src /build/transforms /s /ndl /njh /njs *.xdt'

# Build the Sitecore main platform artifacts
RUN dotnet build /p:Configuration=$env:BUILD_CONFIGURATION /p:Platform='Any Cpu' /p:SolutionDir=/build/ /p:PublishDir=/build/sitecore /p:SitecoreIdentityFolder=/build/identity

# Save the artifacts for copying into other images (see 'cm' and 'rendering' Dockerfiles).
FROM mcr.microsoft.com/windows/nanoserver:1809
WORKDIR /artifacts
# Copy final build artifacts
COPY --from=builder /build/sitecore  ./sitecore/
COPY --from=builder /build/transforms ./transforms/
COPY --from=builder /build/identity/Config ./identity/Config
