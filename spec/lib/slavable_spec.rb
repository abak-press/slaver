require 'spec_helper'

class Some
  extend Slavable

  def some_method
    Bar.create
  end

  def method_wtih_args(name)
    Foo.create(name: name)
  end

  def self.class_method(name)
    Foo.create(name: name)
  end

  def method_with_block
    yield 'some'
  end

  switch :some_method, :method_wtih_args, to: :other
  switch :method_with_block, to: :other

  class << self
    extend Slavable

    switch :class_method, to: :other
  end
end

describe 'swtich' do
  context 'on instance methods' do
    let(:exapmle) { Some.new }
    it 'switches some_method to other connection' do
      exapmle.some_method

      expect(Bar.count).to eq 0
      expect(Bar.on(:other).count).to eq 1
    end

    it 'switches method_with_args to other connection' do
      exapmle.method_wtih_args('test')

      expect(Foo.where(name: 'test').count).to eq 0
      expect(Foo.on(:other).where(name: 'test').count).to eq 1
    end

    it 'switches method with block' do
      exapmle.method_with_block do |name|
         Foo.create(name: name)
      end

      expect(Foo.count).to eq 0
      expect(Foo.on(:other).where(name: 'some').count).to eq 1
    end
  end

  it 'switches class_method to other connection' do
    Some.class_method('test')

    expect(Foo.where(name: 'test').count).to eq 0
    expect(Foo.on(:other).where(name: 'test').count).to eq 1
  end
end
