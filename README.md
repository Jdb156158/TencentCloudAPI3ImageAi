# TencentCloudAPI3ImageAi
腾讯云V3签名方法之iOS，使用腾讯云AI能力实现人体分析中的自定义人像分割，在对图片进行二值化处理，苹果自带API人脸识别判断，自动或者手动人像抠图等

# 腾讯云V3签名方法之iOS
1：因为此案例中使用了腾讯云神图·人体分析（Body Analysis）基于腾讯优图领先的人体分析算法，提供人像分割、人体检测、行人重识别（ReID）等服务。支持识别图片或视频中的半身人体轮廓，并将其与背景进行分离；支持通过人体检测，识别行人的穿着、体态等属性信息，实现跨摄像头跨场景下行人的识别与检索。可应用于人像抠图、背景特效、行人搜索、人群密度检测等场景。

2：但是在使用人体分析、人像分割的API前需要做签名验证，但是腾讯的技术文档都是针对后台实现的，腾讯云封装的 API 配套的 7 种常见的编程语言 SDK，已经封装了签名和请求过程，均已开源，支持 Python、Java、PHP、Go、NodeJS、.NET、C++。没有支持iOS和安卓的，最后谷歌找到一篇文章中有大佬总结了iOS的方法，文章链接：<https://cloud.tencent.com/developer/article/1672824> 
然后还给了github的demo:
OC : https://github.com/williammyuan/tencentcloud-ios
Swift : https://cloud.tencent.com/developer/article/1602241
我试了oc版本的是好的，可以使用

3：实现效果
