---
title: 不使用默认路径的 cmake 项目管理
date: 2024-01-28 21:30:00
tags:
- cmake
categories:
- 编程语言
---
没有 sudo，自己放一个路径，咋整？

<!--more-->

### PATH

linux环境变量，指定从哪里找可执行文件，地球人都知道

### CMAKE_INSTALL_PREFIX

指定编译出来产物后make install到哪里。默认似乎是 `/usr/local`，如果要自己指定的话，就 `/home/cyx/xxx/yyy/install`即可。一般在命令行里使用 `cmake -DCMAKE_INSTALL_PREFIX=XXX ..`来将依赖库的编译产物放到一个文件夹里面

### find_package()及其两种模式

https://www.jianshu.com/p/a0915895dbbc

![find_package()模式](/images/cmake/package.png)

上面图从某个博客复制的。find_package()有两种模式，一种是默认的较低级的module模式，一种是较高级的config模式。

- 对于module模式，要指定CMAKE_MODULE_PATH，我们自己要提供FindXXX.cmake
- 对于config模式，要指定CMAKE_PREFIX_PATH，由依赖库提供XXXConfig.cmake

### CMAKE_PREFIX_PATH

config模式用于提示各种依赖项的位置的最常用变量，帮助CMake定位安装在**非标准目录**中的其他软件包、库和二进制文件。在所需的依赖项**不在默认系统路径**中时常常使用。适用于 `find_package()`, `find_program()`, `find_library()`, `find_file()`, `find_path()`

CMAKE_PREFIX_PATH用于定义额外的 bin/lib(64)/include 搜索路径。如果它指定的路径中没有 /bin, /lib(64), /include 后缀， `find_xxx` 命令会为每个路径自动加上 /bin, /lib(64), /include 目录。因此，这个值可以直接设置为我们在CMAKE_INSTALL_PREFIX那一节提到的 `/home/cyx/xxx/yyy/install`（也就是把依赖库的编译产物添加进来了）

指定好该变量以后，find_package()会按照下列的顺序查找xxxConfig.cmake

- `<prefix>/(lib/<arch>|lib*|share)/cmake/<name>*/`
- `<prefix>/(lib/<arch>|lib*|share)/<name>*/`
- `<prefix>/(lib/<arch>|lib*|share)/<name>*/cmake/`
- `<prefix>/<name>*/(lib/<arch>|lib*|share)/cmake/<name>*/`
- `<prefix>/<name>*/(lib/<arch>|lib*|share)/<name>*/`
- `<prefix>/<name>*/(lib/<arch>|lib*|share)/<name>*/cmake/`

CMAKE_PREFIX_PATH既可以通过环境变量导出（ `export CMAKE_PREFIX_PATH=xxx`），也是一个CMake内置变量，可以在命令行上通过 `-D` 选项或者在 CMakeList.txt 中通过 `set` 或者 `list` 命令显式定义。

除了CMAKE_PREFIX_PATH，find_package()还会按照 https://www.cnblogs.com/lidabo/p/16635310.html 里面提到的顺序检查其他变量

### CMAKE_MODULE_PATH

自然就是去哪里找寻FindXXX.cmake了。这个用的少。

### 头文件目录：include_directories()、CPATH、-I、CMAKE_INCLUDE_PATH

它们都是用于添加include目录的东西

**include_directories()**是在**CMakeLists.txt**里面编写的，指定到include那一层，例如 `/home/cyx/xxx/install/include`

C_INCLUDE_PATH、CPLUS_INCLUDE_PATH、**CPATH** 是 **环境变量**，其中 C_INCLUDE_PATH 只对C语言有效，CPLUS_INCLUDE_PATH 只对C++ 有效，CPATH 对两者都有效。

**-I**是敲g++命令行时候使用的参数，作用类似于CPATH 

**CMAKE_INCLUDE_PATH**是为了find_file()和find_path()使用的。find_path()则是为了解决直接编写include_directories设置绝对路径太死板的问题而使用的。find_path()在CMAKE_PREFIX_PATH和CMAKE_INCLUDE_PATH（**因此如果设置了**CMAKE_PREFIX_PATH**就不用设置**CMAKE_INCLUDE_PATH**了**）下找寻头文件。如果找到了，再设置include_directories()，例如：

```
FIND_PATH(myHeader  hello.h)  #名字myHeader随便取,不影响
IF(myHeader)
INCLUDE_DIRECTORIES(${myHeader})
ENDIF(myHeader)
```

### 链接库目录：link_directories()、LIBRARY_PATH、LD_LIBRARY_PATH、-L、CMAKE_LIBRARY_PATH

它们都是用于指定链接库目录的东西。在编译的链接阶段，编译器需要查找得到所有用到的库，包括静态库和动态库。在运行时，需要能够找到动态库

**link_directories()**是在**CMakeLists.txt**中编写的，在**编译时**指定**静态库和动态库**的位置

**LIBRARY_PATH**是**环境变量**，在**编译时**指定**静态库和动态库**的位置

**LD_LIBRARY_PATH**也是**环境变量**，在**运行时**指定**动态库**的位置

**-L**是敲g++命令行时使用的参数，作用类似于LIBRARY_PATH

**CMAKE_LIBRARY_PATH**是为了find_library()使用的。find_library()则是为了解决直接编写include_directories设置绝对路径太死板的问题而使用的。find_library在CMAKE_PREFIX_PATH和CMAKE_LIBRARY_PATH（**因此如果设置了**CMAKE_PREFIX_PATH**就不用设置**CMAKE_LIBRARY_PATH**了**）下找寻库。如果找到了，再设置link_directorie()，例如：

### PKG_CONFIG_PATH

指定package config（.pc）文件，我也不知道有啥用