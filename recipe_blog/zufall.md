---
layout: single
title: "Zufallsrezept"
permalink: /random/
---
<script>
  var posts = [
    {% for post in site.posts %}
      "{{ post.url | relative_url }}"{% unless forloop.last %},{% endunless %}
    {% endfor %}
  ];
  if (posts.length) {
    var target = posts[Math.floor(Math.random() * posts.length)];
    window.location.replace(target);
  }
</script>
<noscript>
  <p>JavaScript is required to redirect automatically. Click a link to open a random recipe:</p>
  <p>
    {% assign random_post = site.posts | sample %}
    <a href="{{ random_post.url | relative_url }}">Read a random post: {{ random_post.title }}</a>
  </p>
</noscript>
