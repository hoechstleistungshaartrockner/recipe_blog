#!/usr/bin/env ruby
require 'yaml'
require 'fileutils'
require 'date'

ROOT = File.expand_path(File.dirname(__FILE__) + '/..')

# Try to locate the site's `_posts` directory in a few common places
CANDIDATE_POST_DIRS = [
  File.join(ROOT, 'recipe_blog', '_posts'),
  File.join(ROOT, '_posts'),
  File.join(ROOT, 'recipe_blog', 'recipe_blog', '_posts')
]
POSTS_DIR = CANDIDATE_POST_DIRS.find { |d| Dir.exist?(d) }
unless POSTS_DIR
  abort "ERROR: cannot find _posts directory. Looked at:\n  #{CANDIDATE_POST_DIRS.join("\n  ")}"
end

# Place generated category pages next to the site's source (sibling of _posts)
SITE_SOURCE = File.dirname(POSTS_DIR)
# Use a non-underscored directory so Jekyll will publish the files
CATEGORY_DIR = File.join(SITE_SOURCE, 'category')

# Collect categories from post front matter
categories = {}
Dir.glob(File.join(POSTS_DIR, '*')) do |post|
  content = File.read(post)
  if content =~ /\A---\s*(.*?)\s*---/m
    yaml_text = $1
    fm = {}
    begin
      fm = YAML.safe_load(yaml_text, permitted_classes: [Time, Date, DateTime], aliases: true) || {}
    rescue => e
      begin
        fm = YAML.load(yaml_text) || {}
      rescue => e2
        warn "Warning: failed to parse front matter for #{post}: #{e2.message}"
        fm = {}
      end
    end

    c = fm['categories'] || fm['category']
    Array(c).each do |cat|
      categories[cat] ||= 0
      categories[cat] += 1
    end
  end
end

def extract_categories_from_yaml_text(yaml_text)
  found = []
  # inline array: categories: [a, b]
  if yaml_text =~ /^\s*categories:\s*\[(.*?)\]/m
    inner = $1
    found = inner.split(',').map { |s| s.strip.gsub(/^['"]|['"]$/, '') }
    return found.compact.uniq
  end

  # block list: capture only the block under the categories: key
  if yaml_text =~ /^\s*categories:\s*\n((?:[ 	-].*\n)+)/m
    block = $1
    block.scan(/^-\s*(.+)$/).each do |m|
      found << m[0].strip.gsub(/^['"]|['"]$/, '')
    end
    return found.compact.uniq unless found.empty?
  end

  # single-line category(ies)
  if yaml_text =~ /^\s*categories:\s*(.+)$/m
    val = $1.strip
    # comma-separated on one line
    if val.include?(',')
      found = val.split(',').map { |s| s.strip.gsub(/^['"]|['"]$/, '') }
    else
      found << val.gsub(/^['"]|['"]$/, '')
    end
    return found.compact.uniq
  end

  if yaml_text =~ /^\s*category:\s*(.+)$/m
    found << $1.strip.gsub(/^['"]|['"]$/, '')
  end

  found.compact.uniq
end

# If YAML parsing failed earlier, do one more pass using regex only
if categories.empty?
  Dir.glob(File.join(POSTS_DIR, '*')) do |post|
    content = File.read(post)
    if content =~ /\A---\s*(.*?)\s*---/m
      yaml_text = $1
      extracted = extract_categories_from_yaml_text(yaml_text)
      Array(extracted).each do |cat|
        categories[cat] ||= 0
        categories[cat] += 1
      end
    end
  end
end

FileUtils.mkdir_p(CATEGORY_DIR)

categories.each do |cat, count|
  filepath = File.join(CATEGORY_DIR, "#{cat}.md")
  if File.exist?(filepath)
    puts "Skipping #{filepath} (already exists)"
  else
    puts "Writing #{filepath}"
    File.open(filepath, 'w', encoding: 'utf-8') do |f|
      f.puts "---"
      f.puts "layout: category"
      f.puts "title: \"#{cat.to_s.gsub('"', '\\"')}\""
      f.puts "category: \"#{cat.to_s.gsub('"', '\\"')}\""
      f.puts "permalink: /category/#{cat}/"
      f.puts "---"
    end
  end
end

puts "Generated #{categories.size} category pages in #{CATEGORY_DIR} (permalinks are under /category/<category>/)."
