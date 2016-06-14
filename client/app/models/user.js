import Model from 'ember-data/model';
import attr from 'ember-data/attr';
import { hasMany } from 'ember-data/relationships';

export default Model.extend({
  jobTitle: attr('string'),
  firstName: attr('string'),
  tribes: hasMany('tribe'),
  books: hasMany('book'),
  stats: attr(),
  questions: hasMany('question'),
  challenges: hasMany('challenge'),
  avatarUrl: attr('string')
});
