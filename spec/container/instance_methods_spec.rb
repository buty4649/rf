describe 'Container internal methods' do
  using RSpec::Parameterized::TableSyntax

  where(:method, :output) do
    'gsub'  | %w[barbar foofoo].join("\n")
    'gsub!' | %w[barbar barbar].join("\n")
    'sub'   | %w[barfoo foofoo].join("\n")
    'sub!'  | %w[barfoo barfoo].join("\n")
  end

  with_them do
    let(:input) { 'foofoo' }
    let(:args) { %('puts #{method}(/foo/, "bar"); _') }
    let(:expect_output) { "#{output}\n" }

    it_behaves_like 'a successful exec'
  end

  where(:method, :output) do
    'tr'  | %w[FOOFOO foofoo].join("\n")
    'tr!' | %w[FOOFOO FOOFOO].join("\n")
  end

  with_them do
    let(:input) { 'foofoo' }
    let(:args) { %('puts #{method}("a-z", "A-Z"); _') }
    let(:expect_output) { "#{output}\n" }

    it_behaves_like 'a successful exec'
  end

  where(:command, :output) do
    'grep(/foo/)'   | 'foo'
    'grep_v(/bar/)' | "foo\nbaz"
    'grep(/foo/){|i| i + "hoge" }' | 'foohoge'
    'grep_v(/bar/){|i| i+ "hoge" }' | "foohoge\nbazhoge"
  end

  with_them do
    let(:input) { %w[foo bar baz].join("\n") }
    let(:args) { %(-s '#{command}') }
    let(:expect_output) { "#{output}\n" }

    it_behaves_like 'a successful exec'
  end

  %w[match m].each do |method|
    describe "Container##{method}" do
      where do
        {
          'String' => {
            condition: '"2 foo baz"',
            output: {
              without_block: "2 foo baz\n",
              with_block: "2\n"
            }
          },
          'Regexp' => {
            condition: '/.*foo.*/',
            output: {
              without_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              with_block: "1\n2\n3\n"
            }
          },
          'TrueClass' => {
            condition: '_1 == "3"',
            output: {
              without_block: "3 foo qux\n",
              with_block: "3\n"
            }
          },
          'FalseClass' => {
            condition: '_1 == "4"',
            output: {
              without_block: '',
              with_block: ''
            }
          },
          'Integer' => {
            condition: '_2 =~ /foo/',
            output: {
              without_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              with_block: "1\n2\n3\n"
            }
          },
          'NilClass' => {
            condition: '_2 =~ /hoge/',
            output: {
              without_block: '',
              with_block: ''
            }
          }
        }
      end

      with_them do
        let(:input) do
          <<~INPUT
            1 foo bar
            2 foo baz
            3 foo qux
          INPUT
        end

        context 'without block' do
          let(:args) { %('#{method} #{condition}') }
          let(:expect_output) { output[:without_block] }

          it_behaves_like 'a successful exec'
        end

        context 'with block' do
          let(:args) { %('#{method}(#{condition}) { _1 }') }
          let(:expect_output) { output[:with_block] }

          it_behaves_like 'a successful exec'
        end
      end
    end
  end

  %w[match? m?].each do |method|
    describe "##{method}" do
      where do
        {
          'String' => {
            condition: '"2 foo baz"',
            output: {
              without_block: "2 foo baz\n",
              with_block: "2 foo baz\n",
              return_value: <<~VALUE
                false
                true
                false
              VALUE
            }
          },
          'Regexp' => {
            condition: '/.*foo.*/',
            output: {
              without_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              with_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              return_value: <<~VALUE
                true
                true
                true
              VALUE
            }
          },
          'TrueClass' => {
            condition: '_1 == "3"',
            output: {
              without_block: "3 foo qux\n",
              with_block: "3 foo qux\n",
              return_value: <<~VALUE
                false
                false
                true
              VALUE
            }
          },
          'FalseClass' => {
            condition: '_1 == "4"',
            output: {
              without_block: '',
              with_block: '',
              return_value: <<~VALUE
                false
                false
                false
              VALUE
            }
          },
          'Integer' => {
            condition: '_2 =~ /foo/',
            output: {
              without_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              with_block: <<~OUTPUT,
                1 foo bar
                2 foo baz
                3 foo qux
              OUTPUT
              return_value: <<~VALUE
                true
                true
                true
              VALUE
            }
          },
          'NilClass' => {
            condition: '_2 =~ /hoge/',
            output: {
              without_block: '',
              with_block: '',
              return_value: <<~VALUE
                false
                false
                false
              VALUE
            }
          }
        }
      end

      with_them do
        let(:input) do
          <<~INPUT
            1 foo bar
            2 foo baz
            3 foo qux
          INPUT
        end

        context 'without block' do
          let(:args) { "'#{method} #{condition}'" }
          let(:expect_output) { output[:without_block] }

          it_behaves_like 'a successful exec'
        end

        context 'with block' do
          let(:args) { "'#{method}(#{condition}) { _1 }'" }
          let(:expect_output) { output[:with_block] }

          it_behaves_like 'a successful exec'
        end

        describe 'return value' do
          let(:args) { "-q 'p #{method}(#{condition}) { _1 }'" }
          let(:expect_output) { output[:return_value] }

          it_behaves_like 'a successful exec'
        end
      end
    end
  end

  describe '#at_exit' do
    context 'when checking return value' do
      let(:input) { 'test' }
      let(:args) { '-q "p at_exit { }"' }
      let(:expect_output) { "nil\n" }

      it_behaves_like 'a successful exec'
    end

    context 'when block is executed on exit' do
      let(:input) { 'test' }
      let(:args) { '"at_exit { puts \"exit block\" }; puts \"main\""' }
      let(:expect_output) do
        <<~OUTPUT
          main
          exit block
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end
end
