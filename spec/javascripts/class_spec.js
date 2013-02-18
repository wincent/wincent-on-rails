describe('class.js', function() {
  describe('Object.subclass', function() {
    var Person;

    beforeEach(function() {
      Person = Object.subclass({
        init: function() { this.initRan = true; },
        greeting: function() { return this.salutation },
        age:  20,
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

    it('allows subclasses to call _super()', function() {
      var Butcher = Person.subclass({
        init: function() {
          this.subclassInitRan = true;
          this._super();
        }
       }), butcher = new Butcher();

      expect(butcher.subclassInitRan).toBe(true);
      expect(butcher.initRan).toBe(true);
    });

    it('does not require that subclasses call _super()', function() {
      var Baker = Person.subclass({
        init: function() {
          this.subclassInitRan = true;
        }
      }), baker = new Baker();

      expect(baker.subclassInitRan).toBe(true);
      expect(baker.initRan).toBeFalsy();
    });

    it('correctly sets `this` when calling _super()', function() {
      var Plumber = Person.subclass({
        greeting: function() {
          // even when running the superclass implementation of greeting(),
          // we expect the plumber saluation to be used
          return this._super() + '!!!';
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

    it('allows _super() functions to call functions in subclasses', function() {
      var Engineer = Person.subclass({
            add: function() { return this.number() + this.number(); },
            number: function() { return 1; }
          }),
          SoftwareEngineer = Engineer.subclass({
            add: function() { return this._super() + 100; },
            number: function() { return 10; }
          });

      expect(new Engineer().add()).toEqual(2);
      expect(new SoftwareEngineer().add()).toEqual(120);
    });

    it('preserves this._super across multiple levels', function() {
      // in other words, when a superclass calls _super(), the subclasses'
      // _super() still works
      var Manager = Person.subclass({
            result: function() { return 10; }
          }),
          HiringManager = Manager.subclass({
            result: function() { return 20 + this._super(); }
          }),
          GeneralManager = HiringManager.subclass({
            result: function() { return this._super() + 100 + this._super(); }
          });

      expect(new HiringManager().result()).toEqual(30);
      expect(new GeneralManager().result()).toEqual(160);
    });

    it('blows up when there is a missing implementation of _super()', function() {
      // caveat: safety valve won't work on browsers that don't support
      // decompilation
      var subclassPerson = function() {
        Person.subclass({
          missing: function() { return (typeof this._super()); }
        });
      };

      expect(subclassPerson).toThrow();
    });
  });
});
