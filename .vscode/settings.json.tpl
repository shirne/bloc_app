{
    // set PATH=%FLUTTER_ROOT%\bin;%PATH%
    // $env:path = $env:FLUTTER_ROOT+"\bin;"+$env:path
    "dart.flutterSdkPath":"D:\\flutter",
    "terminal.integrated.env.windows": {
        "FLUTTER_ROOT":"${config:dart.flutterSdkPath}"
        ,"PATH":"${config:dart.flutterSdkPath}\\bin;${env:Path}"
        //,"PUB_HOSTED_URL":"https://pub.flutter-io.cn"
        //,"FLUTTER_STORAGE_BASE_URL":"https://storage.flutter-io.cn"
    }
}