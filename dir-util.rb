#!/usr/bin/env ruby
#  Copyright (C) 2022 hidenorly
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'optparse'
require 'date'

class FileUtil
	def self.iteratePath(path, matchKey, pathes, recursive, dirOnly, fullMatch=false)
		Dir.foreach( path ) do |aPath|
			next if aPath == '.' or aPath == '..'

			fullPath = path.sub(/\/+$/,"") + "/" + aPath
			if FileTest.directory?(fullPath) then
				if dirOnly then
					if matchKey==nil || ( aPath.match(matchKey)!=nil ) then 
						pathes.push( fullPath )
					end
				end
				if recursive then
					iteratePath( fullPath, matchKey, pathes, recursive, dirOnly )
				end
			else
				if !dirOnly then
					if matchKey==nil || ( aPath.match(matchKey)!=nil ) || (fullMatch && fullPath.match(matchKey)) then
						pathes.push( fullPath )
					end
				end
			end
		end
	end

	def self.getSimplifiedPath(path)
		pos = path.rindex("/")
		path = pos ? path.slice(pos+1, path.length-pos) : path
		return path
	end
end


#---- main --------------------------
options = {
	:targetDirectory => ".",
	:sortOrder => "normal",
	:sortRule => "dir-name",
	:numOutput => 1,
	:outputMode => "relative",
	:filterMatch => nil
}

OptionParser.new do |opts|
	opts.banner = "Usage: targetDirectory [option]"


	opts.on("-t", "--targetDirectory=", "Specify target path (default:#{options[:targetDirectory]})") do |targetDirectory|
		targetDirectory = targetDirectory.to_s
		options[:targetDirectory] = targetDirectory
	end


	opts.on("-o", "--sortOrder=", "Specify normal or reverse (default:#{options[:sortOrder]})") do |sortOrder|
		sortOrder = sortOrder.to_s.downcase
		options[:sortOrder] = sortOrder if sortOrder == "reverse"
	end

	opts.on("-s", "--sortRule=", "Specify dir-name or file-name (default:#{options[:sortRule]})") do |sortRule|
		sortRule = sortRule.to_s.downcase
		options[:sortRule] = sortRule if sortRule == "file-name"
	end

	opts.on("-n", "--numOutput=", "Specify the number of output result (default:#{options[:numOutput]})") do |numOutput|
		numOutput = numOutput.to_i
		options[:numOutput] = numOutput if numOutput>0
	end

	opts.on("-m", "--outputMode=", "Specify output mode: relative or full (default:#{options[:outputMode]})") do |outputMode|
		outputMode = outputMode.to_s.downcase
		options[:outputMode] = outputMode if outputMode == "full"
	end

        opts.on("-f", "--filterMatch=", "Specify regexp match condition (default:#{options[:filterMatch]})") do |filterMatch|
                options[:filterMatch] = filterMatch
        end
end.parse!


result = []
FileUtil.iteratePath( options[:targetDirectory], options[:filterMatch], result, false, ( options[:sortRule] == "dir-name" ) )

if options[:sortOrder] == "reverse" then
	result = result.sort{|a,b| b<=>a}
else
	result = result.sort{|a,b| a<=>b}
end

n = 0
expandPath = options[:outputMode] == "full"
result.each do |aResult|
	if expandPath then
		aResult = File.expand_path( aResult )
	else
		aResult = FileUtil.getSimplifiedPath( aResult )
	end
	puts aResult
	n = n + 1
	break if n == options[:numOutput]
end
