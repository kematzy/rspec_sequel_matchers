require File.dirname(__FILE__) + "/spec_helper"

describe "have_column_matcher" do

  before do
    define_model :item
  end

  subject{ Item }

  describe "messages" do
    describe "without type" do
      it "should contain a description" do
        @matcher = have_column :name
        expect( @matcher.description ).to eq "have a column :name"
      end
      it "should set failure messages" do
        @matcher = have_column :name
        @matcher.matches? subject
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description
      end
    end
    describe "with type as symbol" do
      it "should contain a description" do
        @matcher = have_column :name, :type => :string
        expect( @matcher.description ).to eq "have a column :name with type: 'string'"
      end
      it "should set failure messages" do
        @matcher = have_column :password, :type => :string
        @matcher.matches? subject
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + ' but no such column exists'
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + ' but no such column exists'
      end
    end
    describe "with type as object" do
      it "should contain a description" do
        @matcher = have_column :name, :type => String
        expect( @matcher.description ).to eq "have a column :name with type: 'String'"
      end
      it "should set failure messages" do
        @matcher = have_column :password, :type => String
        @matcher.matches? subject
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + ' but no such column exists'
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + ' but no such column exists'
      end
      it "should explicit found type if different than expected" do
        @matcher = have_column :name, :type => Integer
        @matcher.matches? subject
        explanation = " but found: { type: 'string', db_type: 'varchar(255)' }"
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + explanation
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + explanation
      end
    end
    describe "with max_length" do
      it "should contain a description" do
        @matcher = have_column :name, :type => :string, :max_length => 100
        expect( @matcher.description ).to eq "have a column :name with type: 'string' and max_length: 100"
      end
      it "should set failure messages" do
        @matcher = have_column :name, :type => :string, :max_length => 1
        @matcher.matches? subject
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + " but found: { type: 'string', db_type: 'varchar(255)', max_length: '255' }"
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + " but found: { type: 'string', db_type: 'varchar(255)', max_length: '255' }"
      end
    end
    describe "with max_length and Decimal" do
      it "should contain a description" do
        @matcher = have_column :price, :type => Float
        expect( @matcher.description ).to eq "have a column :price with type: 'Float'"
      end
      it "should set failure messages" do
        @matcher = have_column :price, :type => :float
        @matcher.matches? subject
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + " but found: { type: 'float', db_type: 'double precision' }"
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + " but found: { type: 'float', db_type: 'double precision' }"
      end
    end
    describe "with default" do
      it "should contain a description" do
        @matcher = have_column :name, :type => :string, :default => "default value"
        expect( @matcher.description ).to eq "have a column :name with type: 'string' and default: 'default value'"
      end
      it "should set failure messages" do
        @matcher = have_column :name, :type => :string, :default => 'default value'
        @matcher.matches? subject
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + " but found: { type: 'string', db_type: 'varchar(255)', default: '' }"
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + " but found: { type: 'string', db_type: 'varchar(255)', default: '' }"
      end
    end
    describe "on anonymous Sequel::Model class" do
      it "should set failure messages" do
        @matcher = have_column :password
        @matcher.matches? Sequel::Model(:comments)
        expect( @matcher.failure_message ).to eq "expected Comment to " + @matcher.description + ' but no such column exists'
        expect( @matcher.failure_message_when_negated ).to eq "expected Comment to not " + @matcher.description + ' but no such column exists'
      end
    end
    describe "on Sequel::Model class" do
      it "should set failure messages" do
        @matcher = have_column :password
        @matcher.matches? Item
        expect( @matcher.failure_message ).to eq "expected Item to " + @matcher.description + ' but no such column exists'
        expect( @matcher.failure_message_when_negated ).to eq "expected Item to not " + @matcher.description + ' but no such column exists'
      end
    end
    describe "on Sequel::Model instance" do
      it "should set failure messages" do
        @matcher = have_column :password
        @matcher.matches? Item.new
        expect( @matcher.failure_message ).to eq "expected #<Item @values={}> to " + @matcher.description + ' but no such column exists'
        expect( @matcher.failure_message_when_negated ).to eq "expected #<Item @values={}> to not " + @matcher.description + ' but no such column exists'
      end
    end
  end

  describe "matchers" do
    it{ is_expected.to have_column(:name) }
    it{ is_expected.to have_column(:name, :type => :string) }
    it{ is_expected.to have_column(:name, :type => String) }
    it{ is_expected.not_to have_column(:password) }
    it{ is_expected.not_to have_column(:name, :type => :integer) }
  end

end
