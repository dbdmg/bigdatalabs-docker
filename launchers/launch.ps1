$URL = "http://localhost:8001"

# check if any arguments were provided
if ($args.Count -eq 0) {
    Write-Host "Invalid number of input parameters specified"
    exit 1
} else {
    # check if the path is valid
    if (!(Test-Path -Path $args[0] -PathType Container)) {
        Write-Host "Folder $($args[0]) does not exist"
        exit 2
    }
}

# check if the container is already running
$count = (docker ps | Select-String -Pattern "bdlabs").Count
if ($count -ge 1) {
    Write-Host "Found a bigdatalab container already running... Either stop it with 'docker kill bdlabs' or connect to it at $URL" -ForegroundColor Red
    exit 1
}

Write-Host "Launching the service... open this URL on the browser $URL" -ForegroundColor Red
Write-Host "You can stop the container either with CTRL+C or with 'docker kill bdlabs'" -ForegroundColor Red
Write-Host "You can check if the container is still running with 'docker ps -a'" -ForegroundColor Red

# launch the docker container with the specified directory
docker run -e BIGDATA_LISTEN_PORT=8001 -it --rm -p 8001:8001 -v "$($args[0]):/vscode/workspace" --name bdlabs lccol/bigdatalabs:v1.0.0
