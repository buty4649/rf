describe 'Expression option (-e)' do
  let(:input) { load_fixture('text/test.txt') }

  context 'with single -e option' do
    let(:args) { "text -e '_.upcase'" }
    let(:expect_output) do
      <<~OUTPUT
        1 FOO
        2 BAR
        3 BAZ
        4 FOOBAR
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with multiple -e options' do
    let(:args) { "text -e '_.upcase' -e '_.reverse'" }
    let(:expect_output) do
      <<~OUTPUT
        OOF 1
        RAB 2
        ZAB 3
        RABOOF 4
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with multiple expressions and filtering' do
    let(:args) { "text -e '/foo/' -e '_.upcase'" }
    let(:expect_output) do
      <<~OUTPUT
        1 FOO
        4 FOOBAR
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with regex in -e option' do
    let(:args) { "text -e '/bar/'" }
    let(:expect_output) do
      <<~OUTPUT
        2 bar
        4 foobar
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'with complex expressions' do
    let(:args) { "text -e '_.split' -e '_.first' -e '_.to_i' -e '_. > 2'" }
    let(:expect_output) do
      <<~OUTPUT
        3
        4
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'when using NR in multiple expressions' do
    let(:args) { "text -e 'NR.odd?' -e '_.split.last + \" (NR: \" + NR.to_s + \")\"'" }
    let(:expect_output) do
      <<~OUTPUT
        foo (NR: 1)
        baz (NR: 2)
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'when using NR after filtering' do
    let(:args) { "text -e '/foo/' -e '\"filtered line NR: \" + NR.to_s'" }
    let(:expect_output) do
      <<~OUTPUT
        filtered line NR: 1
        filtered line NR: 2
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end

  context 'when using NR with complex filtering chain' do
    let(:args) { "text -e 'NR > 1' -e 'NR < 4' -e '_.split.last + \" (filtered NR: \" + NR.to_s + \")\"'" }
    let(:expect_output) do
      <<~OUTPUT
        bar (filtered NR: 1)
        baz (filtered NR: 2)
        foobar (filtered NR: 3)
      OUTPUT
    end

    it_behaves_like 'a successful exec'
  end
end
