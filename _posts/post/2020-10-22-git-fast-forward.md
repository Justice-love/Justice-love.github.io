---
layout: post
title:  "Git Fast Forward"
date:   2020-10-22
excerpt: "git revert fast forward"
feature: https://cdn.justice-love.com/image/jpg/bjfj1.jpg
tag:
- git
comments: true
---

## 背景

当你的一个merge请求是fast forward merge，如果需要回退你这个merge请求，需要如何处理

## 操作

<figure>
    <img src="{{ site.staticUrl }}/image/png/fast_forward.png" />
</figure>

1. 使用`git reflog`查看commit信息，注意，这里`git reflog`指令后最好带上对应的分支名， 如`git reflog testBranch`
2. 找到对应的Fast Forward点，比如上图的`testBranch@{0}`
3. checkout到对应的分支
3. 回退到Fast Forward之前的代码，找到Fast Forward之前的最后一个commit点，然后执行git reset，例如`git reset --keep testBranch@{1}`
4. 建议基于回退的代码重建个新分支
