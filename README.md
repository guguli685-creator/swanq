# SwanQ Creative Hub

SwanQ Creative Hub 是一个轻量、干净的静态资源索引页，用来整理创意设计相关的入口链接。

官网地址：

```text
https://guguli685-creator.github.io/swanq/
```

## 项目特点

- 纯静态页面，无需后端。
- 支持 GitHub Pages 部署。
- 支持搜索资源标题。
- 支持标签页分组，例如 `[PS]`、`[AI]`、`[AE]`、`[PR]`。
- 资源数据独立维护，只需要编辑 `resources.txt`。
- 作者管理入口接入 GitHub 编辑页，由 GitHub 负责登录和仓库写入权限。

## 资源更新方式

编辑仓库里的 `resources.txt`，不用修改 `index.html`。

一条资源写两行：

```text
资源标题
资源链接
```

示例：

```text
[PS]
创意工具资料入口
https://example.com

[AI]
设计工具资料入口
https://example.com
```

没有链接时，第二行写 `#`：

```text
创意工具资料入口
#
```

## 作者管理

作者管理页面：

```text
https://github.com/guguli685-creator/swanq/edit/main/resources.txt
```

登录拥有仓库写入权限的 GitHub 账号后，可以编辑并提交资源列表。其他用户可以访问网站，但不能保存仓库修改。

## GitHub Pages 部署设置

推荐设置：

```text
Source: Deploy from a branch
Branch: main
Folder: /root
```

## 文件说明

```text
index.html      网站页面
resources.txt   资源数据
README.md       项目说明
.nojekyll       GitHub Pages 静态发布配置
```

## 维护规则

- 一条资源使用两行：标题和链接。
- 多条资源之间建议空一行。
- 使用 `[分类名]` 创建标签页。
- 以 `#` 开头的行会被忽略。
- 单独一个 `#` 可作为未补充链接。
