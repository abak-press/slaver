require 'spec_helper'

class Some
  extend Slavable

  def some_method
    Bar.create
  end

  def method_with_args(name)
    Foo.create(name: name)
  end

  def self.class_method(name)
    Foo.create(name: name)
  end

  def method_with_block
    yield 'some'
  end

  def assign=(name)
    Foo.create(name: name)
  end
  switch :assign=, to: :other

  def check_method?(name)
    Foo.where(name: name).exists?
  end
  switch :check_method?, to: :other

  def bang_method!(name)
    Foo.create!(name: name)
  end
  switch :bang_method!, to: :other

  switch :some_method, :method_with_args, to: :other
  switch :method_with_block, to: :other

  class << self
    extend Slavable

    switch :class_method, to: :other
  end
end

describe 'switch' do
  context 'on instance methods' do
    let(:example) { Some.new }
    it 'switches some_method to other connection' do
      example.some_method

      expect(Bar.count).to eq 0
      expect(Bar.on(:other).count).to eq 1
    end

    it 'switches method_with_args to other connection' do
      example.method_with_args('test')

      expect(Foo.where(name: 'test').count).to eq 0
      expect(Foo.on(:other).where(name: 'test').count).to eq 1
    end

    it 'switches method with block' do
      example.method_with_block do |name|
         Foo.create(name: name)
      end

      expect(Foo.count).to eq 0
      expect(Foo.on(:other).where(name: 'some').count).to eq 1
    end

    it 'switches method with assign' do
      example.assign = 'name'

      expect(Foo.count).to eq 0
      expect(Foo.on(:other).where(name: 'name').count).to eq 1
    end

    it 'switches boolean method' do
      Foo.on(:other).create(name: 'question')

      expect(example.check_method?('question')).to be_truthy
    end

    it 'switches bang method' do
      example.bang_method!('bang')

      expect(Foo.count).to eq 0
      expect(Foo.on(:other).where(name: 'bang').count).to eq 1
    end
  end

  it 'switches class_method to other connection' do
    Some.class_method('test')

    expect(Foo.where(name: 'test').count).to eq 0
    expect(Foo.on(:other).where(name: 'test').count).to eq 1
  end
end
