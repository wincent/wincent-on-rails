describe('class.js', function() {
  describe('Class.subclass', function() {
    var Person;

    beforeEach(function() {
      Person = Class.subclass({
        init: function() { this.initRan = true; },
        greeting: function() { return this.salutation },
        age: 20,
        salutation: 'Hi'
      });

    });

    it('calls the init() function on instantiation', function() {
      expect(new Person().initRan).toBe(true);
    });

    it('permits setting properties on the prototype', function() {
      expect(new Person().age).toEqual(20);
    });

    it('allows subclasses to override properties', function() {
      var Ninja = Person.subclass({ age: 25 });
      expect(new Ninja().age).toEqual(25);
    });

    it('does not allow subclasses to mutate superclass properties', function() {
      var Cowboy = Person.subclass({ age: 18 });
      expect(new Cowboy().age).toEqual(18);
      expect(new Person().age).toEqual(20); // still
    });

    it('looks for missing properties on the superclass', function() {
      var Farmer = Person.subclass({});
      expect(new Farmer().age).toEqual(20);
    });

    it('traverses multiple levels looking for missing properties', function() {
      var Doctor = Person.subclass({}),
          BrainSurgeon = Doctor.subclass({});
      expect(new BrainSurgeon().age).toEqual(20);
    });

    it('allows subclasses to call superclass method', function() {
      var Butcher = Person.subclass({
        init: function() {
          this.subclassInitRan = true;
          Butcher.superclass.init.call(this);
        }
       }), butcher = new Butcher();

      expect(butcher.subclassInitRan).toBe(true);
      expect(butcher.initRan).toBe(true);
    });

    it('does not require that subclasses call superclass method', function() {
      var Baker = Person.subclass({
        init: function() {
          this.subclassInitRan = true;
        }
      }), baker = new Baker();

      expect(baker.subclassInitRan).toBe(true);
      expect(baker.initRan).toBeFalsy();
    });

    it('correctly sets `this` when calling superclass methods', function() {
      var Plumber = Person.subclass({
        greeting: function() {
          // even when running the superclass implementation of greeting(),
          // we expect the plumber saluation to be used
          return Plumber.superclass.greeting.call(this) + '!!!';
        },
        salutation: 'Hey!'
      });

      expect(new Plumber().greeting()).toEqual('Hey!!!!');

    });

    it('looks for missing functions on the superclass', function() {
      var Samurai = Person.subclass({});
      expect(new Samurai().greeting()).toEqual('Hi');
    });

    it('traverses multiple levels looking for missing functions', function() {
      var SmallChild = Person.subclass({}),
          SmallerChild = SmallChild.subclass({});
      expect(new SmallerChild().greeting()).toEqual('Hi');
    });

    it('treats subclasses as instances of their ancestors', function() {
      var Male = Person.subclass({}),
          AmericanMale = Male.subclass({}),
          AfricanAmericanMale = AmericanMale.subclass({});

      expect(new Person() instanceof Object).toBe(true);
      expect(new Person() instanceof Male).toBe(false);
      expect(new Person() instanceof AmericanMale).toBe(false);
      expect(new Person() instanceof AfricanAmericanMale).toBe(false);

      expect(new Male() instanceof Object).toBe(true);
      expect(new Male() instanceof Person).toBe(true);
      expect(new Male() instanceof AmericanMale).toBe(false);
      expect(new Male() instanceof AfricanAmericanMale).toBe(false);

      expect(new AmericanMale() instanceof Object).toBe(true);
      expect(new AmericanMale() instanceof Person).toBe(true);
      expect(new AmericanMale() instanceof Male).toBe(true);
      expect(new AmericanMale() instanceof AfricanAmericanMale).toBe(false);

      expect(new AfricanAmericanMale() instanceof Object).toBe(true);
      expect(new AfricanAmericanMale() instanceof Person).toBe(true);
      expect(new AfricanAmericanMale() instanceof Male).toBe(true);
      expect(new AfricanAmericanMale() instanceof AfricanAmericanMale).toBe(true);
    });

    it('allows superclass functions to call functions in subclasses', function() {
      var Engineer = Person.subclass({
            add: function() { return this.number() + this.number(); },
            number: function() { return 1; }
          }),
          SoftwareEngineer = Engineer.subclass({
            add: function() {
              return SoftwareEngineer.superclass.add.call(this) + 100;
            },
            number: function() { return 10; }
          });

      expect(new Engineer().add()).toEqual(2);
      expect(new SoftwareEngineer().add()).toEqual(120);
    });

    it('preserves superclass relation across multiple levels', function() {
      // in other words, when a superclass calls its own superclass function,
      // the subclasses' superclass calls still work
      var Manager = Person.subclass({
            result: function() { return 10; }
          }),
          HiringManager = Manager.subclass({
            result: function() {
              return 20 + HiringManager.superclass.result.call();
            }
          }),
          GeneralManager = HiringManager.subclass({
            result: function() {
              return GeneralManager.superclass.result.call() + 100 +
                GeneralManager.superclass.result.call();
            }
          });

      expect(new HiringManager().result()).toEqual(30);
      expect(new GeneralManager().result()).toEqual(160);
    });

    describe('without an explicit init() function', function() {
      it('can subclass', function() {
        var subclassWithoutInit = function() { Class.subclass({}); };
        expect(subclassWithoutInit).not.toThrow();
      });

      it('constructs working instances', function() {
        var Empty = Class.subclass({
          size: function() { return 0; }
        }), Full = Empty.subclass({
          size: function() { return Full.superclass.size.call(this) + 10; }
        });

        expect(new Full().size()).toEqual(10);
      });

      it('still uses the superclass init() function', function() {
        var Weak = Person.subclass({});
        expect(new Weak().initRan).toBe(true);
      });

      it('passes through argument to the superclas init() function', function() {
        var Special = Class.subclass({
          init: function(a, b) {
            this.a = a;
            this.b = b;
          }
        }), Ordinary = Special.subclass({});
        expect(new Ordinary(1, 2).a).toBe(1);
        expect(new Ordinary(1, 2).b).toBe(2);
      });
    });
  });
});
