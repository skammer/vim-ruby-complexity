" File:        ruby-complexity.vim
" Description: Ruby cyclomatic complexity analizer
" Author:      Max Vasiliev <vim@skammer.name>
" Licence:     WTFPL
" Version:     0.0.1
"
" This will add cyclomatic complexity annotations to your source code. It is
" no longer wrong (as previous versions were!)


if !has('signs')
    finish
endif
if !has('ruby')
    finish
endif

ruby << EOF

require 'rubygems'
require 'optparse'
require 'flog'

class Flog
  def in_method(name, file, line, endline=nil)
    endline = line if endline.nil?
    method_name = Regexp === name ? name.inspect : name.to_s
    @method_stack.unshift method_name
    @method_locations[signature] = "#{file}:#{line}:#{endline}"
    yield
    @method_stack.shift
  end

  def process_defn(exp)
    in_method exp.shift, exp.file, exp.line, exp.last.line do
      process_until_empty exp
    end
    s()
  end

  def process_defs(exp)
    recv = process exp.shift
    in_method "::#{exp.shift}", exp.file, exp.line, exp.last.line do
      process_until_empty exp
    end
    s()
  end

  def process_iter(exp)
    context = (self.context - [:class, :module, :scope])
    context = context.uniq.sort_by { |s| s.to_s }

    if context == [:block, :iter] or context == [:iter] then
      recv = exp.first

      # DSL w/ names. eg task :name do ... end
      if (recv[0] == :call and recv[1] == nil and recv.arglist[1] and
          [:lit, :str].include? recv.arglist[1][0]) then
          msg = recv[2]
          submsg = recv.arglist[1][1]
          in_klass msg do                           # :task
            in_method submsg, exp.file, exp.line do # :name
              process_until_empty exp
            end
          end
          return s()
      end
    end
    add_to_score :branch

    exp.delete 0 # TODO: what is this?

    process exp.shift # no penalty for LHS

    penalize_by 0.1 do
      process_until_empty exp
    end

    s()
  end

  def return_report
    complexity_results = {}
    # io.puts "%8.1f: %s" % [total, "flog total"]
    # io.puts "%8.1f: %s" % [average, "flog/method average"]

    # return if option[:score]

    max = option[:all] ? nil : total * THRESHOLD

    # output_details io, max

    each_by_score max do |class_method, score, call_list|
      # self.print_score io, class_method, score

      location = @method_locations[class_method]
      if location then
        line, endline = location.match(/.+:(\d+):(\d+)/).to_a[1..2]
        complexity_results[line] = [score, class_method, endline]
      end
    end
    complexity_results

  ensure
    self.reset
  end

end



def show_complexity(results = {})
  VIM.command ":silent sign unplace file=#{VIM::Buffer.current.name}"
  results.keys.sort { |a, b| a <=> b }.each do |line_number|
    complexity = case results[line_number][0]
      when 0..7 then "low_complexity"
      when 7..14 then "medium_complexity"
      else "high_complexity"
    end
    (line_number..results[line_number][2]).each do |line|
      VIM.command ":sign place #{line} line=#{line} name=#{complexity} file=#{VIM::Buffer.current.name}"
    end
  end
end
EOF

function! ShowComplexity()
ruby << EOF
options = {
      :quiet    => true,
      :continue => false,
      :all      => true
    }

flogger = Flog.new options
flogger.flog VIM::Buffer.current.name
show_complexity flogger.return_report
EOF

" no idea why it is needed to update colors each time
" to actually see the colors
" hi low_complexity guifg=#004400 guibg=#004400
" hi medium_complexity guifg=#bbbb00 guibg=#bbbb00
" hi high_complexity guifg=#ff2222 guibg=#ff2222
endfunction

hi SignColumn guifg=fg guibg=bg
hi low_complexity guifg=#004400 guibg=#004400
hi medium_complexity guifg=#bbbb00 guibg=#bbbb00
hi high_complexity guifg=#ff2222 guibg=#ff2222

sign define low_complexity text=XX texthl=low_complexity
sign define medium_complexity text=XX texthl=medium_complexity
sign define high_complexity text=XX texthl=high_complexity

autocmd! BufReadPost,BufWritePost,FileReadPost,FileWritePost *.rb call ShowComplexity()
