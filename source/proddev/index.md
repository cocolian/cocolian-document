---
layout: 	source
title: 		"支付产品技术群"
author: 	"支付产品技术群"
date:       2018-02-26 12:00:00 
categories:	['source','management']
---
{% assign posts = site.categories['proddev'] | sort : "date" | reverse %}
| 标题 | 分享人 | 聊天记录数 | 
|------|--------|------------|  
{% for post in posts%}| [{{ post.title }}]({{ post.url | prepend: site.baseurl }}) &nbsp;&nbsp;| {{ post.author }} &nbsp;| {{ post.lines }} &nbsp;|  
{% endfor %}
