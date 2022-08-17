Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value '192.168.50.4	primary	primary.vm';
Add-Content -Path C:\Windows\System32\drivers\etc\hosts -Value '192.168.50.41	replica	replica.vm';
[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$True};

$webClient = New-Object System.Net.WebClient;
$webClient.DownloadFile('https://primary.vm:8140/packages/current/install.ps1', 'install.ps1');

C:\Windows\System32\install.ps1 "main:certname=windows.vm";
