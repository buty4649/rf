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
