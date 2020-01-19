# wson 之 viml 转码器

## 运行需求

vim8 或以上。

## 以命令行工具安装

可执行的 vim 脚本只能在 linux 中使用，windows 请用插件方式。

```bash
./install [$HOME | /usr]
```

若不指定安装路径前缀 `prefix` 则默认安装在 `$HOME` 家目录下。可执行脚本被安装
在 `$prefix/bin/` 下，运行时支持脚本安装在 `$prefix/lib/vex/` 目录下。

请确保 `$prefix/bin` 是系统 `$PATH` 路径中，其内的 `vex` 与 `wson-encode.vim`
与 `wson-decode.vim` 具有可执行权限。

使用方式：

```bash
$ wson-encode.vim {}
$ wson-encode.vim path/to/file.json
$ wson-decode.vim 表也
$ wson-decode.vim path/to/file.wson
```

如果直接将文本置于命令行参数，则将结果直接输出至 stdout ，如果参数是文件名，则
也将结果输出至文件（同名不同后缀），stdout 输出实际保存至的文件名。

## 以 vim 插件方式安装

另见 https://github.com/lymslive/vim-wenyan

该插件关于 wson 提供如下几个命令

* `:WsonEncode` 将 json 字符串转为 wson，直接显示在消息区，如无参数，
  将当前编辑文件视为 json 文件转为 wson 文件并保存。
* `:WsonDecode` 将 wson 字符串转为 json，直接显示在消息区，如无参数，
  将当前编辑文件视为 wson 文件转为 json 文件并保存。

转换文件时，按同名文件保存，更换后缀名，不会覆盖已有文件，如有重名，自动再加
`_1` `_2` 后缀区分。

* `:WsonConfig [pretty=1 simple=1]` 配置 `Encode/Decode` 选项
  - `pretty=1` 指定 `Encode` 成 wson 时缩进排版
  - `simple=1` 指定使用简体关键字

默认使用繁体关键字，压缩单行格式输出。
