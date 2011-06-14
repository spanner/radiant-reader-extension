#--
# Copyright (c) 2011 Ryan Grove <ryan@wonko.com>
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the 'Software'), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#++

class Sanitize
  module Config
    GENEROUS = {
      :elements => %w[
        a b blockquote br caption cite code dd del dl dt em h1 h2 h3 h4 h5 h6 i img li ol p pre small span strike strong sub sup table tbody td th thead tr u ul
      ],

      :attributes => {
        :all         => ['dir', 'lang', 'title', 'class'],
        'a'          => ['href'],
        'blockquote' => ['cite'],
        'img'        => ['align', 'alt', 'height', 'src', 'width'],
        'ol'         => ['start', 'reversed', 'type'],
        'ul'         => ['type'],
        'th'         => ['colspan', 'rowspan'],
        'td'         => ['colspan', 'rowspan']
      },

      :protocols => {
        'a'          => {'href' => ['ftp', 'http', 'https', 'mailto', :relative]},
        'blockquote' => {'cite' => ['http', 'https', :relative]},
        'del'        => {'cite' => ['http', 'https', :relative]},
        'img'        => {'src'  => ['http', 'https', :relative]},
      }
    }
  end
end