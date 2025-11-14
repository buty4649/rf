describe 'ImplicitCalculable features' do
  context 'when String is implicity converted' do
    %i[Integer Float].each do |klass|
      where(:case_name, :args, :expect_output) do
        %i[< <= > >=].map do |mark|
          left = random_number(klass)
          right = random_number(klass)
          statement = %("#{left}" #{mark} #{right})
          answer = left.__send__(mark, right)

          [
            "##{mark} with #{klass} argument",
            %(-q 'p #{statement}'),
            "#{answer}\n"
          ]
        end
      end

      with_them do
        let(:input) { '1' }

        it_behaves_like 'a successful exec'
      end
    end
  end

  %i[Integer Float].each do |klass|
    context "when #{klass} is implicity converted" do
      where(:case_name, :args, :expect_output) do
        %w[+ - * /].map do |mark|
          left = random_number(klass)
          statement = %(#{left} #{mark} "1")
          answer = left.__send__(mark, 1)

          [
            "##{mark} with String argument",
            %('#{statement}'),
            "#{answer}\n"
          ]
        end
      end

      with_them do
        let(:input) { '' }

        it_behaves_like 'a successful exec', input: '1'
      end

      where(:case_name, :args, :expect_output) do
        %i[< <= > >=].map do |mark|
          left = random_number(klass)
          right = random_number(klass)
          statement = %(#{left} #{mark} "#{right}")
          answer = left.__send__(mark, right)

          [
            "##{mark} with String argument",
            %(-q 'p #{statement}'),
            "#{answer}\n"
          ]
        end
      end

      with_them do
        let(:input) { '' }

        it_behaves_like 'a successful exec', input: '1'
      end
    end
  end

  context 'when NilClass is implicity converted' do
    using RSpec::Parameterized::TableSyntax

    describe '#+ with argument' do
      where(:input, :expect_output) do
        %w[1 2 3].join("\n")       | "6\n"
        %w[1.1 2.2 3.3].join("\n") | "6.6\n"
        %w[foo bar baz].join("\n") | "foobarbaz\n"
      end

      with_them do
        let(:args) do
          %w[-q 's+=_1; at_exit { puts s }']
        end

        it_behaves_like 'a successful exec'
      end
    end

    describe '#<< with String argument' do
      let(:input) { %w[foo bar baz].join("\n") }
      let(:args) do
        %w[-q 's<<=_1; at_exit { p s }']
      end
      let(:expect_output) do
        <<~OUTPUT
          ["foo", "bar", "baz"]
        OUTPUT
      end

      it_behaves_like 'a successful exec'
    end
  end
end
