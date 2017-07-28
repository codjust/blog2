<script> async src="https://dn-lbstatics.qbox.me/busuanzi/2.3/busuanzi.pure.mini.js">
</script>

<header class="post-header">

	<{% if theme.seo %}h2{% else %}h1{% endif %} class="post-title" itemprop="name headline">{{ page.title }}</{% if theme.seo %}h2{% else %}h1{% endif %}>

{% if page.description %}
	<div class="post-meta">
            <span id="busuanzi_container_site_pv">
             &nbsp; | &nbsp;Total visited <span id="busuanzi_value_site_pv"></span> times.
             </span>
		<div class="post-description">{{ page.description }}
        </div>
    </div>
{% endif %}

</header>
