describe 'Container internal methods' do
  using RSpec::Parameterized::TableSyntax

  where(:method, :expect_output) do
    'gsub'  | %w[barbar foofoo].join("\n")
    'gsub!' | %w[barbar barbar].join("\n")
    'sub'   | %w[barfoo foofoo].join("\n")
    'sub!'  | %w[barfoo barfoo].join("\n")
  end

  with_them do
    let(:input) { 'foofoo' }
    let(:args) { %('puts #{method}(/foo/, "bar"); _') }

    it_behaves_like 'a successful exec'
  end

  where(:method, :expect_output) do
    'tr'  | %w[FOOFOO foofoo].join("\n")
    'tr!' | %w[FOOFOO FOOFOO].join("\n")
  end

  with_them do
    let(:input) { 'foofoo' }
    let(:args) { %('puts #{method}("a-z", "A-Z"); _') }

    it_behaves_like 'a successful exec'
  end

  where(:command, :expect_output) do
    'grep(/foo/)'   | %w[foo].join("\n")
    'grep_v(/bar/)' | %w[foo baz].join("\n")
    'grep(/foo/){|i| i + "hoge" }' | %w[foohoge].join("\n")
    'grep_v(/bar/){|i| i+ "hoge" }' | %w[foohoge bazhoge].join("\n")
  end

  with_them do
    let(:input) { %w[foo bar baz].join("\n") }
    let(:args) { %(-s '#{command}') }

    it_behaves_like 'a successful exec'
  end

  %w[match m].each do |method|
    describe "Container##{method}" do
      where do
        {
          'String' => {
            condition: '"2 foo baz"',
            output: {
              without_block: '2 foo baz',
              with_block: '2'
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
              with_block: %w[1 2 3].join("\n")
            }
          },
          'TrueClass' => {
            condition: '_1 == "3"',
            output: {
              without_block: '3 foo qux',
              with_block: '3'
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
              with_block: %w[1 2 3].join("\n")
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
          let(:args) { %('#{method} #{condition} { _1 }') }
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
              without_block: '2 foo baz',
              with_block: '2 foo baz',
              return_value: %w[false true false].join("\n")
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
              return_value: %w[true true true].join("\n")
            }
          },
          'TrueClass' => {
            condition: '_1 == "3"',
            output: {
              without_block: '3 foo qux',
              with_block: '3 foo qux',
              return_value: %w[false false true].join("\n")
            }
          },
          'FalseClass' => {
            condition: '_1 == "4"',
            output: {
              without_block: '',
              with_block: '',
              return_value: %w[false false false].join("\n")
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
              return_value: %w[true true true].join("\n")
            }
          },
          'NilClass' => {
            condition: '_2 =~ /hoge/',
            output: {
              without_block: '',
              with_block: '',
              return_value: %w[false false false].join("\n")
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
          let(:args) { "'#{method} #{condition} { _1 }'" }
          let(:expect_output) { output[:with_block] }

          it_behaves_like 'a successful exec'
        end

        describe 'return value' do
          let(:args) { "-q 'p #{method} #{condition} { _1 }'" }
          let(:expect_output) { output[:return_value] }

          it_behaves_like 'a successful exec'
        end
      end
    end
  end
end
