require 'rails_helper'

RSpec.describe PaymentController, type: :controller do
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
    context 'with no cookie' do
      it 'charge the right amount and redirect to payment_thanks' do
        allow(Stripe::Charge).to receive(:create).with(amount: 3500,
                                                       currency: 'eur',
                                                       source: '1234',
                                                       description: '1 Parcours Bloomr',
                                                       receipt_email: 'loulou@lou.com',
                                                       metadata: { 'info_client' => 'loulou - 44 ans - loulou@lou.com' })

        post :create, first_name: 'loulou', email: 'loulou@lou.com', age: '44', stripeToken: '1234'

        expect(response).to redirect_to(payment_thanks_path)
      end
    end

    context 'with sujetdubac cookie' do
      it 'charge the right amount, set the right source and redirect to payment_thanks' do
        allow(Stripe::Charge).to receive(:create).with(amount: 990,
                                                       currency: 'eur',
                                                       source: '1234',
                                                       description: '1 Parcours Bloomr',
                                                       receipt_email: 'loulou@lou.com',
                                                       metadata: {
                                                         'info_client' => 'loulou - 44 ans - loulou@lou.com',
                                                         'source' => 'sujetdubac'
                                                       })

        request.cookies[:sujetdubac] = true
        post :create, first_name: 'loulou', email: 'loulou@lou.com', age: '44', stripeToken: '1234'

        expect(response).to redirect_to(payment_thanks_path)
      end
    end
  end
end
