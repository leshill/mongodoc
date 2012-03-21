module ActiveModelBehavior
  share_as :AnActiveModel do
    ::RSpec::Matchers.define :be_a_boolean do
      match do |actual|
        [ true, false ].include?(actual)
      end
    end

    it { should respond_to(:to_model) }
    it { should respond_to(:to_key) }
    it { should respond_to(:to_param) }

    it { should respond_to(:valid?) }
    its(:valid?) { should be_a_boolean }

    it { should respond_to(:persisted?) }
    its(:persisted?) { should be_a_boolean }

    its(:class) { should respond_to(:model_name) }

    context "the model name" do
      subject do
        described_class.model_name
      end

      it                  { should be_kind_of(String) }
      its(:human)         { should be_kind_of(String) }
      its(:partial_path)  { should be_kind_of(String) }
      its(:singular)      { should be_kind_of(String) }
      its(:plural)        { should be_kind_of(String) }
    end

    context "when its not persisted" do
      subject do
        obj = described_class.new
        obj.stub!(:persisted?).and_return(false)
        obj
      end

      its(:to_key)   { should be_nil }
      its(:to_param) { should be_nil }
    end

    it { should respond_to(:errors) }

    context "errors" do
      subject do
        described_class.new.errors
      end

      it { should respond_to(:[]) }
      it { should respond_to(:full_messages) }

      context "[:hello]" do
        it { subject[:hello].should be_an_instance_of(Array) }

        its(:full_messages) { should be_an_instance_of(Array) }
      end
    end
  end
end

