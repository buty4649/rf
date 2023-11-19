describe 'String class features' do
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
