%i[Integer Float].each do |klass|
  describe "#{klass} class features" do
    where(:case_name, :args, :expect_output) do
      %w[+ - * /].map do |mark|
        left = random_number(klass)
        statement = %(#{left} #{mark} "1")
        answer = left.__send__(mark, 1)

        [
          "##{mark} with String argument",
          %('#{statement}'),
          answer.to_s
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
          answer.to_s
        ]
      end
    end

    with_them do
      let(:input) { '' }

      it_behaves_like 'a successful exec', input: '1'
    end
  end
end
