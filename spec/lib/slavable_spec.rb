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

  switch :some_method, :method_wtih_args, to: :other

  class << self
    extend Slavable

    switch :class_method, to: :other
  end
end

describe Slaver do
  it 'switches some_method to other connection' do
    s = Some.new

    s.some_method

    expect(Bar.count).to eq 0
    expect(Bar.on(:other).count).to eq 1
  end

  it 'switches method_with_args to other connection' do
    s = Some.new

    s.method_wtih_args('test')

    expect(Foo.where(name: 'test').count).to eq 0
    expect(Foo.on(:other).where(name: 'test').count).to eq 1
  end

  it 'switches class_method to other connection' do
    Some.class_method('test')

    expect(Foo.where(name: 'test').count).to eq 0
    expect(Foo.on(:other).where(name: 'test').count).to eq 1
  end
end
