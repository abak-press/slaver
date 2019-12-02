require 'spec_helper'

describe Slaver::Proxy do
  describe 'connection methods delegation' do
    context 'when proxy connection does not respond to called method' do
      it 'does not respond and raises NameError' do
        expect(Foo.on(:other).connection.respond_to?(:not_existed_method)).to eq(false)
        expect { Foo.on(:other).connection.method(:not_existed_method) }.to raise_error(NameError)
        expect { Foo.on(:other).connection.not_existed_method }.to raise_error(NameError)
      end
    end

    context 'when proxy connection responds to called method' do
      let(:query) { "SELECT COUNT(*) FROM #{Foo.quoted_table_name} WHERE name = 'other_1'" }

      it 'responds to method by calling it on proxy connection' do
        Foo.on(:other).create!(name: 'other_1')
        Foo.on(:other).create!(name: 'other_2')

        expect(Foo.on(:other).connection.respond_to?(:select_value)).to eq(true)
        expect(Foo.on(:other).connection.method(:select_value)).to be
        expect(Foo.on(:other).connection.select_value(query).to_i).to eq(1)
        expect(Foo.connection.select_value(query).to_i).to eq(0)
      end
    end
  end
end
