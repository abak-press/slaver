require 'spec_helper'

describe Slaver do
  describe '#on' do
    context 'valid usage' do
      it 'creates record in other db' do
        Foo.on(:other).create(name: 'test')

        expect(Foo.count).to eq 0

        expect(Foo.on(:test_other).count).to eq 1
      end

      context 'with method chain' do
        it 'works with where' do
          Foo.on(:other).create(name: 'test')

          expect(Foo.where(name: 'test').on(:other).first).to be
          expect(Foo.where(name: 'test').first).not_to be
        end

        it 'works with joins' do
          foo = Foo.on(:other).create(name: 'test')
          Bar.on(:other).create(foo: foo)

          expect(Bar.on(:other).joins(:foo).where(foos: {name: 'test'}).first).to be
        end

        it 'works with raw queries' do
          Foo.on(:other).create(name: 'test')

          result_other =
              ActiveRecord::Base.on(:other).connection.select_all("SELECT * FROM foos WHERE name = 'test'").first
          result =
              ActiveRecord::Base.connection.select_all("SELECT * FROM foos WHERE name = 'test'").first

          expect(result_other).to be
          expect(result).not_to be
        end
      end

      it 'allow using one connection for miltiple querries' do
        Foo.on(:other).create(name: 'test')

        connection = ActiveRecord::Base.on(:other).connection

        expect(connection.select_all('SELECT * FROM foos').first).to be
        expect(connection.select_all('SELECT * FROM foos').first).to be
      end

      it 'can be chained multiple times' do
        foo_model = Foo.on(:other)
        foo_model.on(:test)
        foo_model.create

        expect(Foo.count).to eq 1
      end

      it 'uses default connection on non production environment' do
        Foo.on(:not_existing).create(name: 'test')

        expect(Foo.count).to eq 1
      end
    end

    context 'invalid usage' do
      it 'raises error if unexisting configuration provided on production env' do
        Rails.env = 'production'
        expect { Foo.within(:not_existing) {} }.to raise_error ArgumentError
        Rails.env = 'test'
      end
    end
  end

  describe '#within' do
    context 'valid usage' do
      it 'yeilds to other connection' do
        Foo.within(:other) do
          Foo.create
        end

        expect(Foo.count).to eq 0

        Foo.within(:test_other) do
          expect(Foo.count).to eq 1
        end
      end

      it 'yeilds only for one model' do
        Foo.within(:other) do
          Bar.create
        end

        expect(Bar.on(:other).count).to eq 0
        expect(Bar.count).to eq 1
      end

      it 'works with multiple queries' do
        Foo.on(:other).create(name: 'test')
        Foo.within(:other) do
          test = Foo.find_by_name('test')
          test.update_attributes(name: 'test2')
        end

        expect(Foo.on(:other).find_by_name('test2')).to be
      end

      context 'on ActiveRecord::Base' do
        it 'change connections for every descedant' do
          ActiveRecord::Base.within(:other) do
            Foo.create
            Bar.create
          end

          expect(Foo.first).not_to be
          expect(Bar.first).not_to be

          ActiveRecord::Base.within(:other) do
            expect(Foo.first).to be
            expect(Bar.first).to be
          end
        end

        it 'can be combined with on method' do
          Foo.on(:other).create
          Bar.create

          ActiveRecord::Base.within(:other) do
            expect(Foo.first).to be
            expect(Bar.on(:test).first).to be
          end
        end
      end

      context 'with "on" method' do
        it 'works properly with simple usage' do
          Foo.within(:other) do
            Foo.create(name: 'test')
            Foo.on(:test).create(name: 'test2')
            expect(Foo.find_by_name('test')).to be
          end

          expect(Foo.find_by_name('test2')).to be
        end

        it 'works with combination of on' do
          Foo.within(:other) do
            Foo.create(name: 'test')
            Foo.on(:test).on(:other).on(:test).create(name: 'test2')
            expect(Foo.find_by_name('test')).to be
            expect(Foo.find_by_name('test2')).not_to be
          end

          expect(Foo.find_by_name('test2')).to be
        end

        it 'works with nesting' do
          Foo.within(:other) do
            Foo.create(name: 'test')
            Foo.within(:test) do
              Foo.on(:other).create(name: 'test2')
            end
            expect(Foo.find_by_name('test')).to be
            expect(Foo.find_by_name('test2')).to be
          end

          expect(Foo.find_by_name('test2')).not_to be
        end
      end

      it 'uses default connection on non production environment' do
        Foo.within(:not_existing) do
          Foo.create
        end

        expect(Foo.count).to eq 1
      end

      it 'changes only one db' do
        Foo.within(:test_other) do
          Foo.create
          expect(Foo.count).to eq 1
        end

        expect(Foo.count).to eq 0

        Foo.within(:other) do
          expect(Foo.count).to eq 1
        end
      end

      it 'works with associations' do
        Foo.within(:other) do
          foo = Foo.create
          bar = Bar.create(foo: foo)

          expect(bar.foo).to be
        end
      end

      context 'nesting' do
        it 'yeilds to other connection twice' do
          Foo.within(:test_other) do
            Foo.create

            Foo.within(:test_other) do
              Foo.create
            end

            expect(Foo.count).to eq 2
          end
        end

        it 'changes second level db' do
          Foo.within(:other) do
            Foo.create

            Foo.within(:test) do
              Foo.create
            end

            expect(Foo.count).to eq 1
          end

          expect(Foo.count).to eq 1
        end
      end
    end

    context 'invalid usage' do
      it 'raises error if unexisting configuration provided on production env' do
        Rails.env = 'production'
        expect { Foo.within(:not_existing) {} }.to raise_error ArgumentError
        Rails.env = 'test'
      end

      it 'does not polute connections if error occured' do
        Foo.within(:other) do
          Foo.create
          Foo.within(:test) { fail } rescue nil
          expect(Foo.count).to eq 1
        end
      end
    end
  end
end
