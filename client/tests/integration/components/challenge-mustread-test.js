import { moduleForComponent, test } from 'ember-qunit';
import Ember from 'ember';
import hbs from 'htmlbars-inline-precompile';
import { make, makeList, manualSetup, mockFindAll } from 'ember-data-factory-guy';
import sinon from 'sinon';
import { initCustomAssert } from '../../assertions/custom';

moduleForComponent('challenge-mustread', 'Integration | Component | challenge mustread', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    this.set('user', make('user', { challenges: [] }));
    this.set('challenges', [make('challenge', {name: 'must read'})]);
    this.get('user').save = sinon.stub();
    this.searchStub = sinon.stub(this.container.lookup('service:book-search'), 'search');
    initCustomAssert(this);
  }
});

let stubAndReturnPromise = (obj, name, result) => {
  let deferred = Ember.RSVP.defer();
  if(result) {
    deferred.resolve(result);
  }
  obj[name] = sinon.stub();
  obj[name].returns(deferred.promise);
  return deferred;
};

test('I can search a book and add it to my collections', function(assert) {
  let [interview, tribes, mustRead] = 
    makeList('challenge', {name: 'interview'}, {name: 'tribes'}, {name: 'must read'});
  mockFindAll('challenge').returns({models: [interview, tribes, mustRead]});

  this.render(hbs`{{challenge-mustread user=user challenges=challenges}}`);

  this.$('input').val('super book');
  
  let deferred = stubAndReturnPromise(this.container.lookup('service:book-search'), 'search');

  this.$('a.search').click();
  assert.templateContains("on cherche dans l'internet");

  Ember.run(() => deferred.resolve([{title: 'titre: un super book'}]));
  
  assert.templateContains('titre: un super book');
  assert.notOk(this.$().text().includes("on cherche dans l'internet"));

  this.$('.title').click();
  assert.equal(this.$('input').length, 0);

  let record = {};
  stubAndReturnPromise(record, 'save', make('book'));
  sinon.stub(this.container.lookup('service:store'), 'createRecord').returns(record);

  Ember.run(() => this.$('a.done').click());
  assert.templateContains('Bien joué !');
});

test('I can search a book and another one', function(assert) {
  this.render(hbs`{{challenge-mustread user=user}}`);

  this.$('input').val('super book');
  this.searchStub.returns({ then(callback) { callback([{title: 'titre: un super book'}]); }});
  this.$('a.search').click();
  this.$('.title').click();

  this.$('.oneAgain').click();
  this.$('input').val('tip top');

  this.searchStub.returns({ then(callback) { callback([{title: 'titre: tip top'}]); }});
  this.$('a.search').click();
  this.$('.title').click();

  assert.templateContains('titre: un super book');
  assert.templateContains('titre: tip top');
});
