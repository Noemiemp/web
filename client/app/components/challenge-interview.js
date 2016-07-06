import Ember from 'ember';

export default Ember.Component.extend({
  step1: true,
  step2: false,
  step3: false,
  observeStep: Ember.observer('step', function(){
    this.updateView();
  }),
  updateView() {
    if(!this.get('step')) { this.set('step', 1); }
    this.showOnly('step' + this.get('step'));
  },
  init() {
    this._super(...arguments);
    this.updateView();
  },
  showOnly(step){
    this.set('step1', false);
    this.set('step2', false);
    this.set('step3', false);
    this.set(step, true);
  },
  toggleDoAuthorize() {
    this.get('user').toggleProperty('doAuthorize');
  },
  actions: {
    displaySpinner() {
      this.set('user.avatarUrl', '');
    },
    updateImage(e, data) {
      this.set('user.avatarUrl', data.result.avatarUrl);
    },
    go_step2(){
      this.set('step', '2');
    },
    go_step3(){ 
      this.get('user.challenges').addObject(this.get('challenges').findBy('name', 'interview'));
      this.get('user.questions').forEach(q => q.save());
      this.get('user').save();
      this.set('step', '3');
    }
  }
});