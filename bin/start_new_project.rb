#!/usr/bin/env ruby

require 'Find'
require 'FileUtils'
require 'Pathname'

# The path to the sample project, relative to this file.
SRC_DIR = File.join(Pathname(__FILE__).dirname, "../src/__PRODUCT_NAME__")

# The current user's real name
DEFAULT_AUTHOR = %x[dscl . -read $HOME RealName | sed -n 's/^ //g;2p'].strip!

class SymbolExpansion
  def initialize
    # map from regexp to substitution value
    @substitutions = {}

    @symbol_values = {}

    # map from symbols we support to the regexps that find them
    @symbols = {
      :product_name      => Regexp.union(/--PRODUCT-NAME--/, /__PRODUCT_NAME__/),
      :organization_id   => Regexp.union(/--ORGANIZATION-ID--/, /__ORGANIZATION_ID__/),
      :organization_name => /__ORGANIZATION_NAME__/,
      :author            => /__AUTHOR__/,
      :date              => /__DATE__/,
      :year              => /__YEAR__/,
    }
  end

  def set_symbol_value(symbol, value)
    re = @symbols[symbol]
    if re.nil?
      raise "Unknown symbol: #{symbol}"
    end

    @symbol_values[symbol] = value
    @substitutions[re] = value
  end

  def value_for_symbol(symbol)
    return @symbol_values[symbol]
  end

  def process_string(str, quote_replacement = false)
    @substitutions.each do |find, replace|
      if quote_replacement && / / =~ replace
        str = str.gsub(find, "\"#{replace}\"")
      else
        str = str.gsub(find, replace)
      end
    end

    str
  end
end

class ProjectBuilder
  def initialize(src_dir, dst_dir, symbols)
    @src_dir = src_dir
    @dst_dir = dst_dir
    @symbols = symbols

    # Default values - using Regexp.union for easier expansion later

    @dirs_to_skip = Regexp.union(/^xcuserdata$/, /^Pods$/)
    @files_to_skip = Regexp.union(/^.DS_Store$/, /^Podfile.lock$/)
    @quote_replacements_in = Regexp.union(/^project\.pbxproj$/)
    @skip_expansion_in = Regexp.union(/^IDETemplateMacros.plist$/)
  end

  def run
    find_files do |path|
      process_file(path)
    end
  end

  private

    def find_files
      puts "find_files in #{@src_dir}"
      Find.find(@src_dir) do |path|
        basename = File.basename(path)

        if FileTest.directory?(path)
          if @dirs_to_skip =~ basename
            # puts "Skipping directory #{basename}"
            Find.prune
          else
            next
          end
        else
          if @files_to_skip =~ basename
            # puts "Skipping file #{basename}"
            next
          else
            s = Pathname.new(@src_dir)
            t = Pathname.new(path)
            rpath = t.relative_path_from(s).to_s
            yield rpath
          end
        end
      end
    end

    def process_file(src_rpath)
      input_filename = File.join(@src_dir, src_rpath)
      quote_replacement = @quote_replacements_in =~ File.basename(input_filename)
      skip_expansion = @skip_expansion_in =~ File.basename(input_filename)

      dst_rpath = @symbols.process_string(src_rpath)
      dst_filename = File.join(@dst_dir, dst_rpath)

      dst_parent = File.split(dst_filename)[0]
      FileUtils.mkdir_p(dst_parent)

      puts "Writing #{dst_filename}"
      File.open(dst_filename, "w") do |output_fh|
        File.open(input_filename).each do |line|
          if skip_expansion
            output_line = line
          else
            output_line = @symbols.process_string(line, quote_replacement)
          end
          output_fh.write(output_line)
        end
      end
    end
end

def get_user_input(prompt, default = nil)
  while true
    if default.nil?
      print "#{prompt}: "
    else
      print "#{prompt} [Default: \"#{default}\"]: "
    end

    value = STDIN.gets.strip!

    if value.empty?
      if default.nil?
        puts "[Error] Value must not be empty\n"
        next
      else
        return default
      end
    end

    if block_given?
      err = yield(value)

      if err.nil?
        return value
      else
        puts "[Error] #{err}\n"
      end
    else
      return value
    end
  end
end

def build_symbols_from_user_input()

  puts <<ORG_NAME

Please specify an organization name. This used in the copyright notice in the
header comment of each source file.

Example: Rocket Insights, Inc.

ORG_NAME

  organization_name = get_user_input("Organization name", "Rocket Insights, Inc.")

  puts <<ORG_ID

Please specify the organization ID in reverse domain name notation. This is
used as the prefix of the bundle identifier.

Example: com.rocketinsights

ORG_ID

  organization_id = get_user_input("Organization ID", "com.rocketinsights") { |value|
    if /^[a-zA-Z0-9_.-]+$/ =~ value
      nil
    else
      "The organization ID must only use alphanumeric characters"
    end
  }

  puts <<PROD_NAME

Please enter the product name. This is used as the project directory, the name
of the Xcode project file, the name of the main app target, and the prefix
of the testing target.

The product name should not contain spaces and should use CamelCase instead
of snake_case.

Example: MyAwesomeProject

PROD_NAME

  product_name = get_user_input("Product name") { |value|
      if /\s/ =~ value
        "The product name should not contain whitespace"
      elsif /_/ =~ value
        "The product name should use CamelCase instead of snake_case"
      else
        nil
      end
  }

  puts <<AUTHOR

Please enter your name.

AUTHOR

  author = get_user_input("Your name", DEFAULT_AUTHOR)
  now = Time.now
  date = now.strftime("%Y-%m-%d")
  year = now.strftime("%Y")

  symbols = SymbolExpansion.new()
  symbols.set_symbol_value(:organization_name, organization_name)
  symbols.set_symbol_value(:organization_id, organization_id)
  symbols.set_symbol_value(:product_name, product_name)
  symbols.set_symbol_value(:author, author)
  symbols.set_symbol_value(:date, date)
  symbols.set_symbol_value(:year, year)

  return symbols
end

def usage()
  STDERR.puts("Usage: start_new_project.rb destination_path")
end

def main
  if ARGV.count != 1
    STDERR.puts "Incorrect number of arguments"
    usage()
    exit(1)
  end

  dst_path = ARGV[0]

  puts <<INTRO

Welcome to the new project builder. This script will copy the starter project
source files to:

  #{dst_path}

We will start by defining some values that will be entered into the source tree.
INTRO

  symbols = build_symbols_from_user_input()
  puts

  proj = ProjectBuilder.new(SRC_DIR, dst_path, symbols)
  proj.run()

  puts <<OUTRO

Your new project has been generated. You should now do the following:

  cd #{dst_path}
  open #{symbols.value_for_symbol(:product_name)}.xcodeproj

Then, in Xcode, you should verify that you can build and run the project.

OUTRO
end

main

