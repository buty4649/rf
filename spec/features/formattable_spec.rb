describe 'Formattable features' do
  describe 'Object formatting methods' do
    context 'with to_json' do
      let(:input) { load_fixture('yaml/hash.yml') }
      let(:args) { 'yaml to_json' }
      let(:expect_output) do
        <<~OUTPUT
          {
            "foo": 1,
            "bar": {
              "baz": [
                "a",
                "b",
                "c"
              ]
            },
            "foo bar": "foo bar"
          }
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with to_yaml' do
      let(:input) { load_fixture('json/hash.json') }
      let(:args) { 'json to_yaml' }
      let(:expect_output) do
        <<~OUTPUT
          foo: 1
          bar:
            baz:
              - a
              - b
              - c
          foo bar: foo bar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with to_base64' do
      let(:input) { load_fixture('text/test.txt') }
      let(:args) { 'to_base64' }
      let(:expect_output) do
        <<~OUTPUT
          MSBmb28=
          MiBiYXI=
          MyBiYXo=
          NCBmb29iYXI=
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe 'Array formatting methods' do
    context 'with to_table' do
      let(:input) { load_fixture('json/table_2d_array.json') }
      let(:args) { 'json -s to_table' }
      let(:expect_output) do
        <<~OUTPUT
          | Name  | Age |
          |-------|-----|
          | Alice | 30  |
          | Bob   | 25  |
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with to_ssv' do
      let(:input) { load_fixture('json/array.json') }
      let(:args) { 'json -s to_ssv' }
      let(:expect_output) do
        <<~OUTPUT
          foo bar baz
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with to_v (alias for to_ssv)' do
      let(:input) { load_fixture('json/array.json') }
      let(:args) { 'json -s to_v' }
      let(:expect_output) do
        <<~OUTPUT
          foo bar baz
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe 'Hash formatting methods' do
    context 'with to_table' do
      let(:input) { load_fixture('json/table_simple_hash.json') }
      let(:args) { 'json to_table' }
      let(:expect_output) do
        <<~OUTPUT
          | name  | age |
          |-------|-----|
          | Alice | 30  |
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with to_ssv' do
      let(:input) { load_fixture('json/table_simple_hash.json') }
      let(:args) { 'json to_ssv' }
      let(:expect_output) do
        <<~OUTPUT
          name Alice
          age 30
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with to_v (alias for to_ssv)' do
      let(:input) { load_fixture('json/table_simple_hash.json') }
      let(:args) { 'json to_v' }
      let(:expect_output) do
        <<~OUTPUT
          name Alice
          age 30
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe 'Kernel#Ssv method' do
    context 'with single argument' do
      let(:input) { load_fixture('text/test.txt') }
      let(:args) { 'Ssv(_)' }
      let(:expect_output) do
        <<~OUTPUT
          1 foo
          2 bar
          3 baz
          4 foobar
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with multiple arguments' do
      let(:input) { load_fixture('json/array.json') }
      let(:args) { 'json -s "Ssv(_, \"extra\", 123)"' }
      let(:expect_output) do
        <<~OUTPUT
          foo bar baz extra 123
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with hash argument' do
      let(:input) { load_fixture('json/table_simple_hash.json') }
      let(:args) { 'json "Ssv(_)"' }
      let(:expect_output) do
        <<~OUTPUT
          name Alice
          age 30
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end

    context 'with array argument' do
      let(:input) { load_fixture('json/array.json') }
      let(:args) { 'json -s "Ssv(_)"' }
      let(:expect_output) do
        <<~OUTPUT
          foo bar baz
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end
end
