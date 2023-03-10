{
    // set PATH=%FLUTTER_ROOT%\bin;%PATH%
    // $env:path = $env:FLUTTER_ROOT+"\bin;"+$env:path
    "dart.flutterSdkPath":"D:\\flutter2.5",
    "terminal.integrated.env.windows": {
        "FLUTTER_ROOT":"${config:dart.flutterSdkPath}"
        ,"PATH":"${config:dart.flutterSdkPath}\\bin;${env:Path}"
    }
}