---
title: 使用lua-cmsgpack序列化和反序列化lua对象
date: 2017-05-25 22:21:22
tags: [lua, redis, messagepack] 
categories: 后端开发那些事儿
front-matter: 
  toc: true
  comments: true
---
lua-cmsgpack是一个开源的MessagePack实现方式、纯C的库，没有任何其它依赖，编译后可以直接被lua调用，目前主要支持Lua 5.1/5.2/5.3 版本。
1、什么是MessagePack？
-----------
官方的解释是：
```
It's like JSON.
but fast and small.
```
<!--more-->
跟JSON及其类似，但是比JSON更快并且占用空间更小，举个官方给出的例子，直接截官方图：

![官方图.png](http://upload-images.jianshu.io/upload_images/3981501-506507d87dc809fb.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
翻译官方的解释：
MessagePack是一种高效的二进制序列化格式， 它允许在多种语言（如JSON）之间交换数据，但它越来越小， 小整数被编码为单个字节，典型的短字符串除了字符串本身之外还需要一个额外的字节。

目前市面上流行的开发语言MessagePack几乎支持，官方的地址为：http://msgpack.org/Lua MessagePack也提供了一套开源库，地址在：https://github.com/fperrad/lua-MessagePack/。

但是，作者使用的是lua-cmsgpack，至于哪个比较优异，作者还没有去比较，主要是先发现了lua-cmsgpack，后面看了下README文件，使用方法应该是差不多的，大家可以拿来参考。

2、编译lua-cmsgpack
---------
lua-cmsgpack包括官方提供的lua-MessagePack都需要自行编译，因为可能平台太多，所以官方没有为每一个平台提供编译好的版本。lua-cmsgpack的github地址为：https://github.com/antirez/lua-cmsgpack
git clone下来之后需要安装cmake工具，mac平台直接在项目目录：
```
cmake .
make
```
即可，当然需要预先安装lua，并且是5.1版本以上的。

主要说下CentOS平台下cmake可能会出现的问题，如果cmake的过程出现以下错误：
```
Could NOT find Lua51 (missing:  LUA_INCLUDE_DIR) 
...
CMake Error at CMakeLists.txt:1 (cmake_minimum_required):
CMake 2.8 or higher is required.  You are running version 2.6.4
Configuring incomplete, errors occurred!
```
出现以上错误的话，需要自行安装lua的一些依赖库，一般：
```
yum -y install lua lua-devel
```
就可以了，如果还不行，再试试下面的命令：
```
yum install ncurses-devel gcc gcc-c++ make
```

编译完成之后会生成cmsgpack.so文件，使用的时候直接require进去即可


3、lua调用例子
---------
```lua
   1 local cmsgpack = require "cmsgpack"
   2
   3 local tba = {1, 2, 3}
   4
   5 local tbb = {
   6     a = 1,
   7     b = 3
   8 }
   9
  10 local msgpack = cmsgpack.pack(tba, tbb)
  11
  12 local res1, res2 = cmsgpack.unpack(msgpack)
  13
  14 for k, v in pairs(res1) do
  15     print(k, v)
  16 end
  17
  18 for i, v in pairs(res2) do
  19     print(i, v)
  20 end
```
运行效果：
```
#lua test_table.lua
1       1
2       2
3       3
a       1
b       3
```

cmsgpack.pack()可以把多个lua对象序列化成一个二进制msgpack，执行反序化的时候会返回对应数量的lua对象，非常的方便。

4、结合redis存储序列化后的msgpack
---------

有趣的是redis也支持MessagePack，因此结合lua和lua-cmsgpack可以产生不错的化学反应，下面是一个简单的例子（结合OpenResty）：
```lua
local cmsgpack  = require "cmsgpack"
local redis     = require "resty.redis"
local red       = redis:new()

local ok, err = red:connect("127.0.0.1", 6379)
if not ok then
   ngx.say("failed to connect: ", err)
   return
  end

local lua_table = {
     a = 1,
     b = 3
}
local msgpack = cmsgpack.pack(lua_table)
local ok, err = red:set("msg",  msgpack)
if not ok then
   ngx.say("failed to set dog: ", err)
   return
end

local ret_pack  = red:get("msg")
local ret_table = cmsgpack.unpack(ret_pack)

ngx.say(ret_table.a + ret_table.b)
```
测试返回结果：
```
4
```
在某些场合还是有不错应用场景的。
