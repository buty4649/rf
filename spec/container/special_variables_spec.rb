describe 'Special Variables' do
  context 'for record variables' do
    where(:name) do
      %w[record $_ _ _0]
    end

    with_them do
      let(:input) { 'foo' }
      let(:args) { "-q 'puts #{name}'" }
      let(:expect_output) { "#{input}\n" }

      it_behaves_like 'a successful exec'
    end
  end

  context 'for fields variables' do
    where(:name) do
      %w[fields $F]
    end

    with_them do
      context 'when record is String' do
        let(:input) { 'foo bar baz' }
        let(:args) { '-q "p $F[0],$F[1],$F[2]"' }
        let(:expect_output) do
          <<~OUTPUT
            "foo"
            "bar"
            "baz"
          OUTPUT
        end

        it_behaves_like 'a successful exec'
      end

      context 'when record is Hash' do
        let(:input) do
          <<~JSON
            {
              "a": 1,
              "b": 2,
              "c": 3
            }
          JSON
        end
        let(:args) { "-j -q 'p #{name}[0],#{name}[1],#{name}[2]'" }
        let(:expect_output) do
          <<~OUTPUT
            ["a", 1]
            ["b", 2]
            ["c", 3]
          OUTPUT
        end

        it_behaves_like 'a successful exec'
      end

      context 'when record is Other class' do
        let(:input) { '1' }
        let(:args) { "-j -q 'p #{name}[0],#{name}[1],#{name}[2]'" }
        let(:expect_output) do
          <<~OUTPUT
            1
            nil
            nil
          OUTPUT
        end

        it_behaves_like 'a successful exec'
      end
    end
  end

  context 'for number of records' do
    where(:name) do
      %w[$. NR]
    end

    with_them do
      let(:input) do
        <<~TEXT
          foo
          bar
          baz
        TEXT
      end
      let(:args) { %('[#{name}, _].join(" ")') }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          2 bar
          3 baz
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end
end
