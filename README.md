# SwanQ Creative Hub

A clean static index for creative design resources.

## Website

```text
https://guguli685-creator.github.io/swanq/
```

## Deploy

This repository is ready for GitHub Pages.

Recommended Pages settings:

- Source: Deploy from a branch
- Branch: main
- Folder: /root

## Author management

The website uses GitHub as the author management system.

Author edit page:

```text
https://github.com/guguli685-creator/swanq/edit/main/resources.txt
```

Only users with write permission to this repository can save changes. Other users can view the page, but cannot commit edits.

## Update resources

Edit `resources.txt` instead of editing `index.html`.

### Basic format

One resource uses two lines:

```text
资源标题
资源链接
```

Example:

```text
创意工具资料入口
https://example.com
```

Use `#` when the link is not ready:

```text
创意工具资料入口
#
```

### Category tabs

Use `[Category]` to create tabs:

```text
[PS]
资源标题
资源链接

[AI]
资源标题
资源链接
```

The website will automatically create tabs such as `全部`, `PS`, and `AI`.

## Rules

- One resource uses two lines: title and link.
- Leave a blank line between resources for readability.
- Lines starting with `#` are comments.
- A single `#` can be used as an empty link.
- Use `[Category]` to group resources into tabs.

## Notice

All listed resources should come from authorized, original, open-source, or publicly available sources.
