Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value '192.168.50.4	master	master.vm';
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$True};

$webClient = New-Object System.Net.WebClient;
$webClient.DownloadFile('https://master.vm:8140/packages/current/install.ps1', 'install.ps1');

C:\Windows\System32\install.ps1 "main:certname=windows.vm";
