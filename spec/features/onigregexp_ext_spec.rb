describe 'OnigRegexpExt features' do
  describe 'OnigRegexp#on method' do
    using RSpec::Parameterized::TableSyntax

    context 'without block' do
      describe 'returns MatchData when match found' do
        where(:pattern, :input) do
          '/foo/'     | 'foobar'
          '/(\d+)/'   | 'test123'
          '/[a-z]+/'  | 'Hello123'
        end

        with_them do
          let(:args) { %(-q 'result = #{pattern}.on; p result.class') }
          let(:expect_output) { "OnigMatchData\n" }

          it_behaves_like 'a successful exec'
        end
      end

      describe 'returns nil when no match' do
        let(:input) { 'test' }
        let(:args) { %(-q 'result = /nomatch/.on; p result') }
        let(:expect_output) { "nil\n" }

        it_behaves_like 'a successful exec'
      end
    end

    context 'with block' do
      describe 'yields $F when match found' do
        where(:pattern, :input, :expect_output) do
          '/(\d+)/'           | 'test123'      | "\"test123\"\n"
          '/([a-z]+)/'        | 'Hello123'     | "\"Hello123\"\n"
          '/(foo|bar)/'       | 'foobar'       | "\"foobar\"\n"
        end

        with_them do
          let(:args) { %(-q '#{pattern}.on { |line| p line }') }

          it_behaves_like 'a successful exec'
        end
      end

      describe 'no match case' do
        let(:input) { 'test' }
        let(:args) { %(-q '/nomatch/.on { |line| p "matched: \#{line}" }') }
        let(:expect_output) { '' }

        it_behaves_like 'a successful exec'
      end
    end

    context 'with explicit string argument' do
      describe 'match against specific string but yield $F' do
        let(:input) { 'original' }
        let(:args) { %(-q '/test/.on("test123") { |line| p line }') }
        let(:expect_output) { "\"original\"\n" }

        it_behaves_like 'a successful exec'
      end

      describe 'returns MatchData when match found' do
        let(:input) { 'original' }
        let(:args) { %(-q 'result = /test/.on("test123"); p result.class') }
        let(:expect_output) { "OnigMatchData\n" }

        it_behaves_like 'a successful exec'
      end

      describe 'returns nil when no match' do
        let(:input) { 'original' }
        let(:args) { %(-q 'result = /nomatch/.on("test123"); p result') }
        let(:expect_output) { "nil\n" }

        it_behaves_like 'a successful exec'
      end
    end
  end

  describe 'IPv4 pattern substitution' do
    using RSpec::Parameterized::TableSyntax

    describe 'basic IPv4 pattern matching' do
      where(:input, :expect_match) do
        # Valid IPv4 addresses
        '192.168.1.1'         | true
        '255.255.255.255'     | true
        '0.0.0.0'             | true
        '1.2.3.4'             | true
        '10.0.0.1'            | true
        '172.16.254.1'        | true
        # Invalid IPv4 addresses - octets > 255
        '1256.0.0.1'          | false
        '256.0.0.1'           | false
        '10.256.0.1'          | false
        '10.0.256.1'          | false
        '10.0.0.256'          | false
        '256.256.256.256'     | false
        '300.300.300.300'     | false
        '999.999.999.999'     | false
        # Invalid IPv4 addresses - wrong segment count
        '192.168.1.1.1'       | false
        '256.0.0.1.1'         | false
        '192.168.1'           | false
        '192.168'             | false
        '192'                 | false
        # Non-IP strings
        'not.an.ip.address'   | false
      end

      with_them do
        let(:args) { %(-q 'result = /(?&ipv4)/.match("#{input}"); p !result.nil?') }
        let(:expect_output) { "#{expect_match}\n" }

        it_behaves_like 'a successful exec'
      end
    end

    describe 'complex patterns with IPv4' do
      context 'when parsing logs' do
        where(:pattern, :input, :expect_match) do
          '/Server: (?&ipv4)/'          | 'Server: 10.0.0.1'                   | true
          '/\[(?&ipv4)\]/'              | '[192.168.1.1]'                      | true
          '/IP: (?&ipv4) Port: \d+/'    | 'IP: 10.0.0.1 Port: 8080'            | true
          '/(?&ipv4):\d+/'              | '127.0.0.1:3000'                     | true
          '/from (?&ipv4) to (?&ipv4)/' | 'from 192.168.1.1 to 192.168.1.100'  | true
          '/(?&ipv4)/'                  | 'This is not an IP: 256.256.256.256' | false
        end

        with_them do
          let(:args) { %(-q 'result = #{pattern}.match("#{input}"); p !result.nil?') }
          let(:expect_output) { "#{expect_match}\n" }

          it_behaves_like 'a successful exec'
        end
      end
    end

    describe 'capturing groups with IPv4 patterns' do
      context 'when extracting IP addresses' do
        let(:input) { 'Server IP: 192.168.1.100 Client IP: 10.0.0.5' }
        let(:args) do
          %(-q 'match = /Server IP: ((?&ipv4)) Client IP: ((?&ipv4))/.match("#{input}"); p [match[1], match[2]]')
        end
        let(:expect_output) { "[\"192.168.1.100\", \"10.0.0.5\"]\n" }

        it_behaves_like 'a successful exec'
      end
    end
  end
end
