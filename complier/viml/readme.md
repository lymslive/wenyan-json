# wson 之 viml 转码器

另见 https://github.com/lymslive/vim-wenyan

暂时先附在 wenyan-lang 的 vim 插件中。完善后计划将 viml 脚本封装为 linux 下的
直接可执行脚本，但 window 下仍是只能用插件方式运行。

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
