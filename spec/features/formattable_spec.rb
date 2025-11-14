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
  end

  describe 'Array formatting methods' do
    context 'with to_table' do
      let(:input) { load_fixture('json/table_2d_array.json') }
      let(:args) { 'json -s to_table' }
      let(:expect_output) do
        <<~OUTPUT
          | Name  |  Age  |
          | ----- | ----- |
          | Alice |  30   |
          |  Bob  |  25   |
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
          | name  |  age  |
          | ----- | ----- |
          | Alice |  30   |
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end
end
