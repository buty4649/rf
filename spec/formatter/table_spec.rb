describe 'Table formatter' do
  describe 'Array#to_table' do
    context 'with 1D array' do
      let(:input) { load_fixture('json/table_1d_array.json') }
      let(:args) { 'json -s "_.to_table"' }
      let(:expect_output) do
        <<~TABLE
          | header1 |
          |---------|
          | header2 |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with 2D array' do
      let(:input) { load_fixture('json/table_2d_array.json') }
      let(:args) { 'json -s "_.to_table"' }
      let(:expect_output) do
        <<~TABLE
          | Name  | Age |
          |-------|-----|
          | Alice | 30  |
          | Bob   | 25  |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with mixed types in 2D array' do
      let(:input) { load_fixture('json/table_mixed_types.json') }
      let(:args) { 'json -s "_.to_table"' }
      let(:expect_output) do
        <<~TABLE
          | String | Number | Boolean |
          |--------|--------|---------|
          | test   | 123    | true    |
          | hello  | 456    | false   |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with empty array' do
      let(:input) { '[]' }
      let(:args) { 'json -s "_.to_table"' }
      let(:expect_output) { "\n" }

      it_behaves_like 'a successful exec'
    end

    context 'with arrays of different lengths' do
      let(:input) { load_fixture('json/table_different_lengths.json') }
      let(:args) { 'json -s "_.to_table"' }
      let(:expect_output) do
        <<~TABLE
          | A | B | C |
          |---|---|---|
          | 1 | 2 |   |
          | X |   |   |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with nil values' do
      let(:input) { load_fixture('json/table_nil_values.json') }
      let(:args) { 'json -s "_.to_table"' }
      let(:expect_output) do
        <<~TABLE
          | Header |
          |--------|
          |        |
          | value  |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end
  end

  describe 'Hash#to_table' do
    context 'with simple hash' do
      let(:input) { load_fixture('json/table_simple_hash.json') }
      let(:args) { 'json "to_table"' }
      let(:expect_output) do
        <<~TABLE
          | name  | age |
          |-------|-----|
          | Alice | 30  |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with hash containing array values' do
      let(:input) { load_fixture('json/table_hash_array_values.json') }
      let(:args) { 'json "to_table"' }
      let(:expect_output) do
        <<~TABLE
          | names | ages |
          |-------|------|
          | Alice | 30   |
          | Bob   | 25   |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with hash containing mixed array and single values' do
      let(:input) { load_fixture('json/table_hash_mixed_values.json') }
      let(:args) { 'json "to_table"' }
      let(:expect_output) do
        <<~TABLE
          | name  | city  | age |
          |-------|-------|-----|
          | Alice | Tokyo | 30  |
          | Bob   |       | 25  |
        TABLE
      end

      it_behaves_like 'a successful exec'
    end

    context 'with empty hash' do
      let(:input) { '{}' }
      let(:args) { 'json "to_table"' }
      let(:expect_output) { "\n" }

      it_behaves_like 'a successful exec'
    end
  end
end
