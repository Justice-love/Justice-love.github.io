---
layout: post
title:  "Git提交统计"
date:   2017-03-15
excerpt: "统计你在GitHub中的提交记录"
tag:
- Git
- GitHub
comments: true
---

### GitHub下某个分支提交统计

运行指令：
``` shell
git log --since="1475233120" --author="$(git config --get user.name)" --pretty=tformat: --numstat | awk  '{del += ($2 + 0)} END {print del }'
```

