import JSONAPIAdapter from 'ember-data/adapters/json-api';

export default JSONAPIAdapter.extend({
   namespace: 'api/v1',
   host: 'http://localhost:3000'
});
