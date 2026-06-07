run:
	bundle exec rake preview

new:
	bundle exec jekyll new blabla

serve:
	bundle exec jekyll serve

serve_drafts:
	bundle exec jekyll serve --draft

generate_tag_pages:
	bundle exec ruby scripts/generate_tag_pages.rb

generate_category_pages:
	bundle exec ruby scripts/generate_category_pages.rb