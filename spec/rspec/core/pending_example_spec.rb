require 'spec_helper'

Rspec::Matchers.define :be_pending_with do |message|
  match do |example|
    example.metadata[:pending] && example.metadata[:execution_result][:pending_message] == message
  end

  failure_message_for_should do |example|
    "expected example to pending with #{message.inspect}, got #{example.metadata[:execution_result][:pending_message].inspect}"
  end
end

describe "an example" do
  context "with no block" do
    it "is listed as pending with 'Not Yet Implemented'" do
      group = Rspec::Core::ExampleGroup.describe('group') do
        it "has no block" 
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('Not Yet Implemented')
    end
  end

  context "with no args" do
    it "is listed as pending with 'No reason given'" do
      group = Rspec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('No reason given')
    end
  end

  context "with a message" do
    it "is listed as pending with the supplied message" do
      group = Rspec::Core::ExampleGroup.describe('group') do
        it "does something" do
          pending("just because")
        end
      end
      example = group.examples.first
      example.run(group.new, stub.as_null_object)
      example.should be_pending_with('just because')
    end
  end

  context "with a block" do
    context "that fails" do
      it "is listed as pending with the supplied message" do
        group = Rspec::Core::ExampleGroup.describe('group') do
          it "does something" do
            pending("just because") do
              3.should == 4
            end
          end
        end
        example = group.examples.first
        example.run(group.new, stub.as_null_object)
        example.should be_pending_with('just because')
      end
    end

    context "that passes" do
      it "raises a PendingExampleFixedError" do
        group = Rspec::Core::ExampleGroup.describe('group') do
          it "does something" do
            pending("just because") do
              3.should == 3
            end
          end
        end
        example = group.examples.first
        example.run(group.new, stub.as_null_object)
        example.metadata[:pending].should be_false
        example.metadata[:execution_result][:status].should == 'failed'
        example.metadata[:execution_result][:exception_encountered].should be_a(Rspec::Core::PendingExampleFixedError)
      end
    end
  end

end
