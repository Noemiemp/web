require 'rails_helper'

RSpec.describe PaymentController, type: :controller do
  before do
    FactoryGirl.create(:campaign, partner: 'default', price: '35.0')
    FactoryGirl.create(:campaign, partner: 'sujetdubac', price: '13.0')
  end

  describe 'GET #index' do
    it 'returns http success' do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe 'GET #thanks' do
    it 'returns http success' do
      get :thanks
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST #create' do
    let(:bloomy) do
      { first_name: 'loulou', email: 'loulou@lou.com', age: '44' }
    end
    let(:payload) { { bloomy: bloomy, stripeToken: '1234' } }

    before do
      allow(Mailchimp).to receive(:subscribe_to_journey)
      allow(Mailchimp).to receive(:send_presentation_email)
      allow(Mailchimp).to receive(:send_rejoindre_communaute_email)
      allow(Stripe::Charge).to receive(:create)
    end

    describe 'the bloomy creation' do
      subject { Bloomy.first }

      before do
        post :create, payload
      end

      it { expect(subject.first_name).to eq('loulou') }
      it { expect(subject.email).to eq('loulou@lou.com') }
      it { expect(subject.age).to eq(44) }
    end

    context 'if it s a gift' do
      let(:gift_payload) { payload.merge(gift: true, buyer_email: 'money@rich.com') }

      let(:stripes_args) do
        { amount: amount, currency: 'eur', source: '1234',
          description: '1 Parcours Bloomr',
          receipt_email: 'money@rich.com', metadata: metadata }
      end

      after do
        post :create, gift_payload
        expect(response).to redirect_to(payment_thanks_path + '?gift=true')
      end

      context 'with no cookie' do
        let(:metadata) do
          { 'info_client' => 'loulou - 44 ans - loulou@lou.com',
            'source' => 'default', 'gift' => true }
        end
        let(:amount) { 3500 }

        it 'charges the right amount and redirect to payment_thanks' do
          expect(Stripe::Charge).to receive(:create).with(stripes_args)
        end

        it 'doesnt subscribe to the journey yet' do
          expect(Mailchimp).not_to receive(:subscribe_to_journey)
        end
      end
    end

    describe 'the stripe charges' do
      let(:stripes_args) do
        { amount: amount, currency: 'eur', source: '1234',
          description: '1 Parcours Bloomr',
          receipt_email: 'loulou@lou.com', metadata: metadata }
      end

      after do
        post :create, payload
        expect(response).to redirect_to(payment_thanks_path + '?gift=false')
      end

      context 'with no cookie' do
        let(:metadata) do
          { 'info_client' => 'loulou - 44 ans - loulou@lou.com',
            'source' => 'default', 'gift' => false }
        end
        let(:amount) { 3500 }

        it 'charges the right amount and redirect to payment_thanks' do
          expect(Stripe::Charge).to receive(:create).with(stripes_args)
        end
      end

      context 'with sujetdubac cookie' do
        let(:metadata) do
          { 'info_client' => 'loulou - 44 ans - loulou@lou.com',
            'source' => 'sujetdubac', 'gift' => false }
        end
        let(:amount) { 1300 }

        it 'charge the right amount,
            set the right source and redirect to payment_thanks' do
          request.cookies[:partner] = 'sujetdubac'
          expect(Stripe::Charge).to receive(:create).with(stripes_args)
        end
      end
    end

    describe 'the journey inscription' do
      after { post :create, payload }

      let(:actions) do
        [:subscribe_to_journey, :send_presentation_email,
         :send_rejoindre_communaute_email]
      end

      it 'subscribes to the journey' do
        actions.each { |s| expect(Mailchimp).to receive(s).once }
      end
    end
  end
end
