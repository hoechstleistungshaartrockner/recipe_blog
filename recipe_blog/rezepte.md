---
layout: single
title: "Rezept-Übersicht"
permalink: /rezepte/
---

Hier findest du eine organisierte Übersicht aller Rezepte in meinem Blog.

{% assign recipe_posts = site.posts | sort: "date" | reverse %}

<ul class="archive__items">
{% for post in recipe_posts %}
  <li class="archive__item">
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
    <span class="archive__item-meta">{{ post.date | date: "%d.%m.%Y" }}</span>
    {% if post.categories %}<span> · {{ post.categories | join: ", " }}</span>{% endif %}
  </li>
{% endfor %}
</ul>
