# BlocApp

基于bloc和flutter_bloc的Flutter APP框架。旨在打造一个包含通用基础功能的项目模板，以减少创建项目的繁琐程度。

## 开始

* 重要提醒：开发上线项目，请修改包名(安卓)和bundle(Apple)
    * 可以直接在android和ios目录修改
    * 可以使用`flutter create --org yourdomain appname` 创建一个空项目，把代码及配置文件复制过去
* 环境配置参考 
    * `https://flutter.cn/docs/get-started/install` (国内)
    * `https://docs.flutter.dev/docs/get-started/install` (国外)

# Features

* 采用BLOC作为状态管理
* 主题自由扩展, 主题切换，多语言
* 辅助脚本 (`bin/` 目录下)
  * 接口和模型生成工具
  * 页面生成工具
  * 路由生成工具
  * 资源文件生成工具
  * 统计工具等...
* API 请求基础设施
* 线上日志查看面板 (utils/console)
* 文件上传任务处理
* 常用工具类及扩展


## 修改启动页和图标

- 按assets/images 中的图片规格制作替换
- 执行命令 flutter pub run flutter_native_splash:create 生成新启动页
- 执行命令 flutter pub run icons_launcher:create 生成新图标

## 生成模型和API

- 支持swagger和openapi格式的json文档生成model和api
- 生成后的文件可能需要手动做一些调整
```
dart run bin/api.dart json文件
```

## 从json生成模型

```
/// json文件可以是 openapi 中components的类型定义，也可以是json格式的数据示例
dart run bin/model.dart json文件
```

## 添加模型和API

- models目录中新增文件，新建类继承自Base
```dart
class ArticleModel implements Base {
  ArticleModel({
    this.articleId = 0,
    this.title = '',
    this.content = '',
    this.createTime,
  });

  /// 为了防止数据异常，这里转换使用工具类 as<T>
  ArticleModel.fromJson(Map<String, dynamic>? json)
      : this(
          articleId: as<int>(json?['article_id']) ?? 0,
          title: as<String>(json?['title'] ?? '',
          content: as<String>(json?['content'] ?? '',
          createTime: as<DateTime>(json?['create_time']),
        );

  int articleId;
  String title;
  String content;
  DateTime? createTime;

  /// 模型克隆功能
  /// 对于可空字段 如果需要再次赋空可以使用Optional传递
  @override
  ArticleModel clone({
    int? articleId,
    String? title,
    String? content,
    Optional<DateTime>? createTime,
  }) => ArticleModel(
    articleId: articleId ?? this.articleId,
    title: title ?? this.title,
    content: content ?? this.content,
    createTime: createTime.absent(this.createTime),
  );

  @override
  Map<String, dynamic> toJson() => {
      'article_id': articleId,
      'title': title,
      'content': content,
      'create_time': createTime?.toString(),
    };
}
```
- 在api中返回并解析该模型，传入解析函数
```dart
class Api {
    ...

    static Future<ApiResult<ArticleModel>> getArticle(int id){
        return await apiService.get(
            'article/detail',
            {
                'id': id,
            },
            dataParser: (d)=>ArticleModel.fromJson(d),
        );
    }

    ...
}
```
这样就可以在使用API时直接用泛型调用来返回对应的模型
```dart
final result = await Api.getArticle(1);
print(result.data);

final result = await ApiService.getInstance().get<ArticleModel>('article/detail');
print(result.data);

//列表
final result = await ApiService.getInstance().get<ModelList<ArticleModel>>('article/list');
print(result.data);
```

## 添加页面

- 执行命令 `dart bin/bloc.dart Pagename`  添加新页面
- 执行命令 `dart bin/bloc.dart Pagename dirname` 在目录dirname中添加新页面

## 生成路由
- 路由文件 globals/routes.dart
- 执行命令 `dart bin/route.dart`  重新生成路由

* 注意
    * 路由生成脚本自动搜索pages下的目录，目录中的page.dart为页面文件
    * 页面文件中定义的第一个类为页面类
    * 页面类可不接收参数，或者接收一个Json? 类型的位置参数（参考login/page.dart)

- 页面状态缓存
在`page.dart` 中的 Widget build(BuildContext context) 方法中找到创建Bloc的代码，如：
```dart
create: (context) => HomeBloc(),
```
增加缓存键名的参数
```dart
create: (context) => HomeBloc('homestate'),
```

## 业务逻辑与UI分离
* 不建议将Controller(ScrollController,RefreshController等) 之类的控制器存入State中，推荐将page 转换为StatefulWidget后写到State属性中
* 不建议将context 传入到bloc中操作，可以在bloc或event中增加回调方法，在处理完业务逻辑后，将成功或失败状态回调至UI

如：在bloc中加入回调，此方法比较固定，在指定页面的指定操作会回调到ui
```dart
/// bloc.dart
class HomeBloc ... {
    final void Function(String errmsg)? onError;
    HomeBloc(this.onError,[String globalKey = '']): ...
}

/// page.dart
_onError(String message){
    // 这里如要使用context，需要将page转换为StatefulWidget
    showDialog(context, (context){
        return AlertDialog(
            content: Text(message),
            actions: <Widget>[
                TextButton(
                    onPressed: () {
                        Navigator.of(context).pop();
                    },
                    child: const Text('好的'),
                ),
            ],
        );
    });
}

...
create: (context) => HomeBloc(_onError,'homestate'),
```

在事件中回调: 此方法比较灵活，每次推送事件都可以绑定一个回调来处理该事件相关的操作
```dart
/// event.dart
class LoadDataEvent extends HomeEvent{
    final void Function(String errmsg)? onError;
    LoadDataEvent(this.onError);
}

/// bloc.dart
HomeBloc([String globalKey = ''])...{
    ...
    on<LoadDataEvent>((event, emit) {
      emit(state.clone(status: Status.loading));
      _loadData(onError: event.onError);
    });
    ...
}

_loadData({void Function(String message)? onError}) async {
    ...

    if(success){
        add(StateChangedEvent(state.clone(...)));
    }else{
        onError?.call('load error');
    }
  }

/// page.dart 中调用
context.read<HomeBloc>().add(LoadDataEvent(_onError));
```
    * 对于加载操作，一般不需要成功回调，因为加载完成就推送状态更新事件，页面数据直接刷新就可以了。
    * 对于表单提交等操作，可能需要事件成功的回调，这种就建议将回调指定到事件上
    * 注意异步操作完成需要更新状态或回调事件时，先通过`isClosed`判断一下页面是否已关闭，类似于StatefulWidget的`mounted`，两者状态是相反的

* 不建议在page的tap或press中写业务逻辑代码，如api请求，大量的计算等
* 建议将相似的组件抽离出来，一是简化了页面布局，二是方便统一调整组件

## 目录结构说明

```tree
lib
|- generated                // 多语言生成文件，不可修改
|- l10n                     // 多语言配置文件，要修改或新增语言项在这里操作
|- src                      // 源文件目录
|   |- globals              // 全局项
|   |- models               // Model目录
|   |  |- base.dart         // 模型基类
|   |  |- ...           
|   |- pages                // 页面目录，创建的页面文件在此目录下，一般一个页面会生成一个子目录
|   |  |- home              // 首页  
|   |  |- login              // 登录页  
|   |  |- settings          // 设置页  
|   |  |- not_found.dart    // 默认的404页
|   |- utils                // 工具库
|   |- wigets               // 组件库
|- main.dart                // 入口文件
```

## 处理assets

* 将文件名后缀 3.0x 等迁移至目录
```
dart bin/assetsx.dart
```
* 生成assets.dart(默认处理images和svgs目录)
```
dart bin/assets.dart
```

## 其它Tools

* 统计代码行数
```
dart bin/lines.dart
```
* 统计依赖次数
```
dart bin/deps.dart
```
* 多分辨率分包素材批量解压
```
// 每个素材一个zip压缩包，放至assets目录下，解压后以压缩包名字命名
dart bin/unzip.dart
```

## 获取安卓密钥的签名
```
keytool -list -v -keystore xxx.jks

# 如果上面没有md5，在安卓目录执行以下命令获取
./gradlew app:signingReport

# 查看公钥
keytool -list -rfc --keystore suolong.jks | openssl x509 -inform pem -pubkey
```

## 注意事项

* 如发现Bug或使用问题，可以提Issue
* 如有好的改进方案，可以提Issue或PR
