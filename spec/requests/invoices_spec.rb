require 'rails_helper'
require 'stripe_mock'

RSpec.describe InvoicesController, type: :request do
  let(:stripe_helper) { StripeMock.create_test_helper }
  before do
    StripeMock.start
    stripe_helper.create_plan(id: 'example-plan-id', name: 'World Domination', amount: 100000, trial_period_days: $trial_period_days)
  end
  after { StripeMock.stop }
  let(:mock_customer) { Stripe::Customer.create }
  let(:mock_subscription) { mock_customer.subscriptions.create(plan: 'example-plan-id') }
  let(:user) { create(:user) }
  let(:invoice) { create(:invoice) }

  describe 'GET /invoices/:id' do
    subject do
      get invoice_path(invoice.id, format: :pdf)
      response
    end

    context 'as a subscribed user' do
      before { sign_in user }

      it 'serves an invoice PDF' do
        expect(subject).to have_http_status(:success)
        expect(subject.header['Content-Type']).to eq 'application/pdf'
      end
    end
  end
end
