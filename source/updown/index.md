---
title: UPDOWNLOADER
date: 2022-02-15 13:43:52
---

http://124.222.102.137/updown/

https://github.com/poorpool/updownloader

## 使用

取得内容时，可以在输入框里输入代码，也可以直接在网站链接后面加上代码。

取得文件：

![file](./images/1-file.png)

取得文本：

![text](./images/2-text.png)

命令行：

```
upload: curl -X POST http://BACKEND_ADDRESS/updown/file -F "file=@YOUR_FILE_PATH"
query:  curl http://BACKEND_ADDRESS/updown/record/YOUR_CODE
```

如果你不幸忘记了 curl 的用法，可以 `curl http://BACKEND_ADDRESS/usage` 来取得上面的用法。

更多内容参见 github 文档。