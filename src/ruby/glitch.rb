#!/usr/bin/env ruby

module Glitch



  # parse out code review comments from file
  # returning an array of Comment objects
  def Glitch.parse_file file
    # @cr one brianm should this detect string vs io?
    p = Parser.new
    File.open file do |f|
      p.parse f, file
    end
  end


  class Parser

    # receives an IO returns an array of Comment instances
    def parse io, file="<none>"
      # @cr one brianm
      # here it takes an IO, good that the name is different
      # from the module function
      c = nil
      ws = nil
      line_no = 0
      io.lines.inject([]) do |rs, line|
        line_no += 1
        if c != nil
          # in a comment
          if line =~ /#{ws}(.*)/
            c << $1
          else
            c = nil
          end
        else
          # not in a comment
          if line =~ /(.*)@cr\s+(\S+)\s+(\S+)\s+(.*)/
            ws = $1
            c = Comment.new $2, $3, file, line_no
            c << $4 unless $4.strip == ""
            rs << c
          end
        end
        rs
      end
    end

  end
  
  class Comment
    attr_accessor :id, :user, :lines, :line_no, :comment, :file
    def initialize id, user, file, line_no
      @line_no = line_no
      @user = user
      @id = id
      @lines = []
      @file = file
    end

    def to_s
      @lines.join("\n")
    end

    def << line
      @lines << line
    end
  end

end

if __FILE__ == $0
  ARGV.each do |arg|
    Glitch.parse_file(arg).each do |c|
      puts <<EOC
--
#{c.file}:#{c.line_no} : #{c.id},  #{c.user}
#{c}
EOC
    end
  end
end
