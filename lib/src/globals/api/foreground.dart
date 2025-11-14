part of '../api.dart';

class ApiForeground extends ApiBase {
  @override
  String get basePath => '';

  /// 微信接口绑定手机号
  Future<ApiResult<Model>> wxBindPhone({
    required String code,
    required String iv,
    required String encryptedData,
  }) async {
    return await apiService.post(
      '${basePath}api/member/index/wxBindPhone',
      {'code': code, 'iv': iv, 'encryptedData': encryptedData},
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 会员资料更新
  Future<ApiResult<Model>> update() async {
    return await apiService.post(
      '${basePath}api/member/index/update',
      {},
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 会员个人设置
  Future<ApiResult<Model>> setting() async {
    return await apiService.post(
      '${basePath}api/member/index/setting',
      {},
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 会员信息
  Future<ApiResult<MemberDTO>> info() async {
    return await apiService.post(
      '${basePath}api/member/index/info',
      {},
      dataParser: (d) => MemberDTO.fromJson(d),
    );
  }

  /// 会员中心首页
  Future<ApiResult<Model>> home() async {
    return await apiService.post(
      '${basePath}api/member/index/home',
      {},
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 绑定手机号
  Future<ApiResult<Model>> bindPhone({
    required String phone,
    required String verifyCode,
  }) async {
    return await apiService.post('${basePath}api/member/index/bindPhone', {
      'phone': phone,
      'verifyCode': verifyCode,
    }, dataParser: (d) => Model.fromJson(d));
  }

  /// 绑定邮箱
  Future<ApiResult<Model>> bindEmail({
    required String email,
    required String verifyCode,
  }) async {
    return await apiService.post('${basePath}api/member/index/bindEmail', {
      'email': email,
      'verifyCode': verifyCode,
    }, dataParser: (d) => Model.fromJson(d));
  }

  /// 微信授权登录/注册
  Future<ApiResult<TokenDTO>> loginByWechat() async {
    return await apiService.post(
      '${basePath}api/auth/wechat_login',
      {},
      dataParser: (d) => TokenDTO.fromJson(d),
    );
  }

  /// 用户注册接口
  Future<ApiResult<TokenDTO>> register() async {
    return await apiService.post(
      '${basePath}api/auth/register',
      {},
      dataParser: (d) => TokenDTO.fromJson(d),
    );
  }

  /// 手机号验证码登录/注册
  Future<ApiResult<TokenDTO>> loginByMobile() async {
    return await apiService.post(
      '${basePath}api/auth/mobile_login',
      {},
      dataParser: (d) => TokenDTO.fromJson(d),
    );
  }

  /// 用户登录接口
  Future<ApiResult<TokenDTO>> login() async {
    return await apiService.post(
      '${basePath}api/auth/login',
      {},
      dataParser: (d) => TokenDTO.fromJson(d),
    );
  }

  /// 获取访客token
  Future<ApiResult<TokenDTO>> guest() async {
    return await apiService.post(
      '${basePath}api/auth/guest',
      {},
      dataParser: (d) => TokenDTO.fromJson(d),
    );
  }

  /// 找回密码接口
  Future<ApiResult<TokenDTO>> forget() async {
    return await apiService.post(
      '${basePath}api/auth/forget',
      {},
      dataParser: (d) => TokenDTO.fromJson(d),
    );
  }

  /// 文章点赞
  Future<ApiResult<Model>> diggArticle({required String id}) async {
    return await apiService.post('${basePath}api/article/digg', {
      'id': id,
    }, dataParser: (d) => Model.fromJson(d));
  }

  /// 文章评论
  Future<ApiResult<Model>> commentArticle({
    required String id,
    required String content,
    String? replyId,
  }) async {
    return await apiService.post('${basePath}api/article/comment', {
      'id': id,
      'content': content,
      if (replyId != null) 'replyId': replyId,
    }, dataParser: (d) => Model.fromJson(d));
  }

  /// 获取系统配置
  Future<ApiResult<Model>> getSettings() async {
    return await apiService.get(
      '${basePath}api/common/settings',
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 获取指定位置的推荐位
  Future<ApiResult<BoothDTO>> getBooth({required String flag}) async {
    return await apiService.get(
      '${basePath}api/common/booth/$flag',
      dataParser: (d) => BoothDTO.fromJson(d),
    );
  }

  /// 获取指定位置的Banner
  Future<ApiResult<BannerDTO>> getBanner({required String flag}) async {
    return await apiService.get(
      '${basePath}api/common/banner/$flag',
      dataParser: (d) => BannerDTO.fromJson(d),
    );
  }

  /// 获取分类列表
  Future<ApiResult<ModelList<CategoryModel>>> list({String? parentId}) async {
    return await apiService.get(
      '${basePath}api/category/list',
      queryParameters: {if (parentId != null) 'parent_id': parentId},
      dataParser: (d) =>
          ModelList.fromJson(d, (m) => CategoryModel.fromJson(m)),
    );
  }

  /// 获取验证码图片
  Future<ApiResult<VerifyImageResp>> verifyImage() async {
    return await apiService.get(
      '${basePath}api/auth/verify_image',
      dataParser: (d) => VerifyImageResp.fromJson(d),
    );
  }

  /// 发送手机验证码
  Future<ApiResult<Model>> sendMobileVerifyCode({
    required String mobile,
    required String verify,
  }) async {
    return await apiService.get(
      '${basePath}api/auth/send_sms_code',
      queryParameters: {'mobile': mobile, 'verify': verify},
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 发送邮箱验证码
  Future<ApiResult<Model>> sendEmailVerifyCode({
    required String email,
    required String verify,
  }) async {
    return await apiService.get(
      '${basePath}api/auth/send_email_code',
      queryParameters: {'email': email, 'verify': verify},
      dataParser: (d) => Model.fromJson(d),
    );
  }

  /// 文章列表
  Future<ApiResult<ModelPage<ArticleDTO>>> list_1({
    String? keyword,
    String? cateId,
    String? page,
    String? pageSize,
  }) async {
    return await apiService.get(
      '${basePath}api/article/list',
      queryParameters: {
        if (keyword != null) 'keyword': keyword,
        if (cateId != null) 'cateId': cateId,
        if (page != null) 'page': page,
        if (pageSize != null) 'pageSize': pageSize,
      },
      dataParser: (d) => ModelPage.fromJson(d, (m) => ArticleDTO.fromJson(m)),
    );
  }

  /// 文章详情
  Future<ApiResult<ArticleDTO>> detail({required String id}) async {
    return await apiService.get(
      '${basePath}api/article/detail/$id',
      dataParser: (d) => ArticleDTO.fromJson(d),
    );
  }
}
