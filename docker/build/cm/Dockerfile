# escape=`

ARG PARENT_IMAGE
ARG SOLUTION_IMAGE
ARG TOOLS_IMAGE
ARG MANAGEMENT_SERVICES_IMAGE
ARG HEADLESS_SERVICES_IMAGE
ARG SPE_IMAGE

FROM ${SOLUTION_IMAGE} as solution
FROM ${TOOLS_IMAGE} as tools
FROM ${MANAGEMENT_SERVICES_IMAGE} AS management_services
FROM ${HEADLESS_SERVICES_IMAGE} AS headless_services
FROM ${SPE_IMAGE} as spe
FROM ${PARENT_IMAGE}

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

WORKDIR C:\inetpub\wwwroot

# Grant access for themes folders to avoid Access to the path 'c:\some\path' is denied.
RUN icacls .\sitecore\shell\themes /grant 'Everyone:(F)' /t /q

# Copy developer tools and entrypoint
COPY --from=tools C:\tools C:\tools

# Add SPE module
COPY --from=spe \module\cm\content C:\inetpub\wwwroot

# Copy and init the JSS / Headless Services Module
COPY --from=headless_services C:\module\cm\content C:\inetpub\wwwroot
COPY --from=headless_services C:\module\tools C:\module\tools

# Copy the Sitecore Management Services Module
COPY --from=management_services C:\module\cm\content C:\inetpub\wwwroot

RUN C:\module\tools\Initialize-Content.ps1 -TargetPath C:\inetpub\wwwroot; `
    Remove-Item -Path C:\module -Recurse -Force;

# Copy solution platform files
COPY --from=solution /artifacts/sitecore/ ./

ARG ENVIRONMENT

COPY --from=solution /artifacts/transforms/ /transforms/solution/
# Perform solution transforms
RUN Get-ChildItem C:\transforms\solution\*\*\platform\web.config.xdt | ForEach-Object { & C:\tools\scripts\Invoke-XdtTransform.ps1 -Path .\web.config -XdtPath $_.FullName }

