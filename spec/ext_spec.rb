require 'spec_helper.rb'

describe "Ruby Object Extensions" do
  context "Conversions" do
    context "Boolean" do
      it "converts from a '1' to true" do
        Boolean.cast_from_string('1').should be_true
      end

      it "converts from a 'tRuE' to true" do
        Boolean.cast_from_string('tRuE').should be_true
      end

      it "converts anything else to false" do
        Boolean.cast_from_string('0').should be_false
      end
    end

    context "Date" do
      it "returns nil for a blank string" do
        Date.cast_from_string('').should be_nil
      end

      it "converts from a string to a Date" do
        date = Date.today
        Date.cast_from_string(date.to_s).should == date
      end
    end

    context "DateTime" do
      it "returns nil for a blank string" do
        DateTime.cast_from_string('').should be_nil
      end

      it "converts from a string to a DateTime" do
        datetime = DateTime.now
        DateTime.cast_from_string(datetime.to_s).should === datetime
      end
    end

    context "Numeric" do
      context "BigDecimal" do
        it "returns nil for a blank string" do
          BigDecimal.cast_from_string('').should be_nil
        end

        it "converts from a string to a BigDecimal" do
          big_decimal = BigDecimal.new("123")
          BigDecimal.cast_from_string(big_decimal.to_s).should == big_decimal
        end
      end

      context "Integer" do
        it "returns nil for a blank string" do
          Integer.cast_from_string('').should be_nil
        end

        it "converts from a string to a Bignum" do
          big_number = 1000000000000
          Integer.cast_from_string(big_number.to_s).should == big_number
        end

        it "converts from a string to a Fixnum" do
          fixnum = 1
          Integer.cast_from_string(fixnum.to_s).should == fixnum
        end
      end
    end

    context "Time" do
      it "returns nil for a blank string" do
        Time.cast_from_string('').should be_nil
      end

      it "converts from a string to a Time" do
        time = Time.now
        Time.cast_from_string(time.to_s).to_s.should == time.to_s
      end
    end
  end
end
