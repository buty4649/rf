require_relative '../../mrblib/rf/version'

describe 'Show version', type: :aruba do
  describe '--version' do
    let(:args) { '--version' }
    let(:expect_output) do
      /^rf #{Rf::VERSION} \(mruby \d\.\d\.\d [0-9a-f]+\)$/
    end

    it_behaves_like 'a successful exec'
  end
end
