---
title: 使用apidoc工具编写自动化API文档
date: 2017-02-04 22:26:42
tags: [apidoc] 
categories: 后端开发那些事儿
---
API文档可以帮助我们快速理解接口的调用方法，因此一份好的API文档其实是非常重要的。但是对于开发者来说编写API文档又是比较耗时，这个时候我们希望有一些工具可以帮助我们节省时间，提升效率，apidoc工具就是其中之一。很多语言都会提供自动化文档的工具，方法也大同小异，我选择的是apidoc，官网是：http://apidocjs.com/
<!--more-->
apidoc主要是通过支持不同语言的注释方法来识别，目前已经支持了以下语言，如图所示，而且新的版本也支持了lua，不过官网的文档还没及时更新。

![a1.png](http://upload-images.jianshu.io/upload_images/3981501-65c09fb800491402.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

我个人认为apidoc最好的使用场景是程序员在完成一个API时按照apidoc的语法在接口文件上面编写接口的调用方法，然后再使用apidoc识别直接生成文档，因为接口的开发者对接口的调用是最为熟悉的，这样可以最小程度的减少后续编写文档的时间。

下面介绍apidoc的使用方法：
### 1、安装工具

#### (1)安装npm包管理工具
```shell
    sudo apt-get install npm
```
#### (2)安装nodejs
```shell
    sudo apt-get install nodejs
```
如果终端输入:node -v会输出版本号则说明安装成功。<br>
#### (3)安装apidoc工具
官网：[http://apidocjs.com](http://apidocjs.com)
```shell
    npm install apidoc -g
```
一般默认会安装在：/usr/local/lib/node_modules/apidoc 目录下。<br>
#### (4)测试apidoc
```shell
    cd /usr/local/lib/node_modules/apidoc
    apidoc -i explame -o doc
```
查看doc目录，里面会生成静态的html文件，直接浏览器打开即可。<br>

### 2、按照apidoc语法编写接口注释

#### (1)准备好lua文件和json配置文件，这里以我的工程为例：
```shell
    mkdir orskycloud-apidoc
    cd orskycloud-apidoc
    mkdir apidoc
    touch apidoc.json
```
apidoc.json:
```json
     {                                                                                                                                          
    "name":"orskycloud API",                                                                                                               
    "version":"1.0.0",                                                                                                 
    "title":"ORSkyCloud API Document",
    "description":"ORSkyCloud开发者指南"
    }                                                                                                                                          
```

api/test.lua
```lua
--[[
@apiDefine Response
@apiParam(response){string} Message 响应信息，接口请求success或failed返回相关信息
@apiParam(response){bool} Successful 是否成功。通过该字段可以判断请求是否到达.
--]]
--[[
@api {POST} http://hcwzq.cn/api/getalldevicesensor.json?uid=* getalldevicesensor
@apiName getalldevicesensor
@apiGroup All
@apiVersion 1.0.1
@apiDescription 获取用户所有设备和传感器信息

@apiParam {string} uid 唯一ID，32位md5值
@apiParam {json} response 响应数据
@apiUse Response


@apiParamExample Example:
POST http://hcwzq.cn/api/getalldevicesensor.json?uid=c81e728d9d4c2f636f067f89cc14862c

@apiSuccessExample {json} Success-Response:
HTTP/1.1 200 OK
{"1":[{
    "createTime":"2016-12-19 23:07:12",
    "deviceName":"Test1",
    "description":"description1",
    "Sensor":[{
        "createTime":"2016-9-12 00:00:00",
        "unit":"kg",
        "name":"weight",
        "designation":"体重"}]
}],
"Message":"success",
"Successful":true
}

@apiErrorExample {json} Error-Response:
HTTP/1.1 200 OK  
{
        "Successful":false,
        "Message": "Device not create yet"
}

--]]
```
这里我省略了我的接口的内容，注意：lua的注释要用--[[ --]]，其它注释方法是无效的，官网我也没看到有介绍，但是用这个亲测可用，哈。文件的注释编写好之后按照第一步的方法使用apidoc生成就可以了。

下面是一些apidoc语法的简单介绍，更加详细的大家去查阅官网的文档(参考博文：http://www.jianshu.com/p/bb5a4f5e588a)：
```
@api {method} path [title]
  只有使用@api标注的注释块才会在解析之后生成文档，title会被解析为导航菜单(@apiGroup)下的小菜单
  method可以有空格，如{POST GET}
@apiGroup name
  分组名称，被解析为导航栏菜单
@apiName name
  接口名称，在同一个@apiGroup下，名称相同的@api通过@apiVersion区分，否者后面@api会覆盖前面定义的@api
@apiDescription text
  接口描述，支持html语法
@apiVersion verison
  接口版本，major.minor.patch的形式

@apiIgnore [hint]
  apidoc会忽略使用@apiIgnore标注的接口，hint为描述
@apiSampleRequest url
  接口测试地址以供测试，发送请求时，@api method必须为POST/GET等其中一种

@apiDefine name [title] [description]
  定义一个注释块(不包含@api)，配合@apiUse使用可以引入注释块
  在@apiDefine内部不可以使用@apiUse
@apiUse name
  引入一个@apiDefine的注释块

@apiParam [(group)] [{type}] [field=defaultValue] [description]
@apiHeader [(group)] [{type}] [field=defaultValue] [description]
@apiError [(group)] [{type}] field [description]
@apiSuccess [(group)] [{type}] field [description]
  用法基本类似，分别描述请求参数、头部，响应错误和成功
  group表示参数的分组，type表示类型(不能有空格)，入参可以定义默认值(不能有空格)
@apiParamExample [{type}] [title] example
@apiHeaderExample [{type}] [title] example
@apiErrorExample [{type}] [title] example
@apiSuccessExample [{type}] [title] example
  用法完全一致，但是type表示的是example的语言类型
  example书写成什么样就会解析成什么样，所以最好是书写的时候注意格式化，(许多编辑器都有列模式，可以使用列模式快速对代码添加*号)

@apiPermission name
  name必须独一无二，描述@api的访问权限，如admin/anyone
```

### 3、最后的效果图：

![a2.png](http://upload-images.jianshu.io/upload_images/3981501-db3935097e573349.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)


![a3.png](http://upload-images.jianshu.io/upload_images/3981501-40d396f45f9e27c3.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

这里只是提供一种方法，有更加省事的途径欢迎大家评论交流，内容错漏之处敬请见谅，谢谢啦。

