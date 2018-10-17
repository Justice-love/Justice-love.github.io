---
layout: post
title:  "求最长公共前缀"
date:   2018-10-17
excerpt: "leetCode题目解析"
feature: https://i.imgur.com/Ds6S7lJ.png
tag:
- python
- leetCode
comments: true
---

## 题目

编写一个函数来查找字符串数组中的最长公共前缀。如果不存在公共前缀，返回空字符串 ""。

示例:

输入: ["flower","flow","flight"]
输出: "fl"

## 解析

1. 对列表按字典序排序
2. 求列表的最大值和最小值的公共部分
3. 证明第一步得到的公共部分对于列表的中间元素同样有效
    1. 设列表长度为3，假设公共部分大于中间元素
        * 由于先对列表进行了字典序排序，所以如果公共部分大于中间元素，则中间元素和最小元素排序颠倒，所以假设不成立
    2. 设列表长度为3，假设公共部分小于中间元素
        * 同理，可得中间元素和最大元素排序颠倒，与事实不符，所以假设不成立
4. 临界条件，列表为空，则返回空字符串即可        

## 解答

``` python
class Solution(object):
    def longestCommonPrefix(self, strs):
        """
        :type strs: List[str]
        :rtype: str
        """
        if not strs:
            return ''
        min_1=min(strs)
        max_1=max(strs)
        for i,value in enumerate(min_1):
            if value!=max_1[i]:
                return min_1[:i]
        return min_1
```