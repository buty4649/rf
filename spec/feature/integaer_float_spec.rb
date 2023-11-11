describe 'Extended addition feature for Integer and Float' do
  where(:case_name, :args, :expect_output) do
    def random_number(klass)
      number = rand(100)
      klass == 'Float' ? number.to_f : number
    end

    %w[Integer Float].product(%w[+ - * /]).map do |klass, mark|
      left = random_number(klass)
      statement = %(#{left} #{mark} "1")
      answer = left.__send__(mark, 1)

      [
        "#{klass}#+ with String argument",
        %('#{statement}'),
        answer.to_s
      ]
    end
  end

  with_them do
    let(:input) { '' }

    it_behaves_like 'a successful exec', input: '1'
  end
end
