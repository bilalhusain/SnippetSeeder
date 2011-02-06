#!/bin/ruby
require 'yaml'

$queryTemplate = "insert into Example (Node, ExampleText, Syntax, Comments) values ('__node__', 'coming soon', 'DUMMY', '');"
$sqlScriptFile = File.new("insertScript.sql", "w")

# make a directory, add appropriate index.html
def mkPublicDir(dir, childNode)
	if (!File.directory?(dir))
		puts "Creating directory '" + dir + "'"
		Dir.mkdir(dir)
	end

	if childNode.class != Hash then
		# leaf node, add example file
		f = File.new(dir + "index.html", "w")
		f.write("Coming soon ...")
		f.close()
		puts "Written (example) index.html to " + dir
	else
		# this is a listing
		f = File.new(dir + "index.html", "w")
		content = ""
		childNode.each_pair do |k, v|
			v.length.times do |i|
				# either directory or file (leaf)
				if v[i].class == Hash
					v[i].each_pair do |vk, vv|
						content += "<li><a href='" + vk + "'>" + vk + "</a></li>"
					end
				else
					content += "<li><a href='" + v[i] + "'>" + v[i] + "</a></li>"
				end
			end
		end
		f.write("<ul>" + content + "</ul>")
		f.close()
		puts "Written (listing) index.html to " + dir
	end
end

# just recurse, because that's how I roll (in mud)
def traverseNode(node, prefix, dirpath)

	# base case
	if node.class != Hash then
		# leaf (=> make directory with example file)
		mkPublicDir(dirpath + node + "/", node)
		$sqlScriptFile.write($queryTemplate.gsub(/__(.*?)__/) { prefix + node } + "\n")
		return
	end

	node.each_pair do |k, v|
		# non-leaf (=> create dir with file listing)
		mkPublicDir(dirpath + k + "/", node) 
		v.length.times do |i|
			traverseNode(v[i], prefix + k + ".", dirpath + k + "/")
		end
	end
end

# yeah! read the file
hash = YAML::load_file('map.yaml')
traverseNode(hash, "", "./") # do it the dirty way, prefix is initialized to blank string
$sqlScriptFile.close()

